
# Swagger docs at ...s/__swagger__/ (needs trailing slash!)
if(Sys.getenv('PORT') == '') Sys.setenv(PORT = 8000)

#' @apiTitle R Google Sheets Formulas
#' @apiDescription These endpoints allow the user to create custom functions in Google spreadsheets which call R functions.

#* Plot a histogram
#* @png
#* @param n The number of observations
#* @get /baseplot
function(n = 1000){
  
  err <- tryCatch({
    
    rand <- rnorm(as.numeric(n))
    hist(rand, main = paste0("rand(", n, ")"))
  
  }, error = function(e) e)
  
  return(glue::glue('Error: {err$message}'))
}

#* Plot a histogram with ggplot!
#* @png
#* @param n The number of observations
#* @get /ggplot
function(n = 1000){
  
  err <- tryCatch({
    
    require(ggplot2)
    require(dplyr)
    require(glue)
    
    df <- data.frame(rand = rnorm(as.numeric(n)), stringsAsFactors = F)
    
    g <- df %>% ggplot(aes(rand)) +
      geom_histogram(fill = 'red') +
      theme_minimal() + 
      ggtitle('A sample ggplot histogram', glue('rand({n})'))
    
    print(g)
    
  }, error = function(e) e)
  
  return(glue::glue('Error: {err$message}'))
}


#* Use an MNIST model to predict which digit a given image represents.
#* You MUST be using samterfa/rmlsheets
#* @param imgURL The URL of the image to predict on.
#* @post /mnist
function(imgURL){
  
  err <- tryCatch({
    
    require(keras)
    
    on.exit(file.remove('tmp.png'))
    download.file(imgURL, destfile = 'tmp.png')
    
    img <- image_load(path = 'tmp.png', grayscale = T, target_size = c(28, 28))
    
    model <- load_model_hdf5('/home/rstudio/mnist/model.h5', compile = F)
    
    results <- model %>% predict(img %>% array_reshape(c(1, 28, 28, 1))) %>% which.max() - 1
    
    return(results)
    
  }, error = function(e) {return(e)})
  
  return(glue::glue("Error: {err$message}"))
}

#* Run an R script on spreadsheet data.
#* @param rscript The R script to run.
#* @param a A variable to pass into the rscript.
#* @param b A variable to pass into the rscript.
#* @param c A variable to pass into the rscript.
#* @param d A variable to pass into the rscript.
#* @param e A variable to pass into the rscript.
#* @post /rscript
function(rscript, a = NULL, b = NULL, c = NULL, d = NULL, e = NULL){
  
  err <- tryCatch({
    
    require(dplyr)
    require(stringr)
    require(purrr)
    require(glue)
    
    if(str_detect(rscript, 'ggplot')) require(ggplot2)
    
    vars <- as.list(environment()) %>% compact() %>% modify_at(c('rscript'), .f = function(x) 'deleteMe') %>% discard(~ all(unlist(.x) == 'deleteMe'))
    
    for(var in names(vars)){
      
      varvalue <- eval(parse(text = glue('vars${var}')))
      
      # If single value
      if(is.null(nrow(varvalue))) {
        
        print('single value')
        
        modvalue <- varvalue
        
        eval(parse(text = glue::glue('{var} <- modvalue'))) 
        
        next()
      }
      
      # If numerical column vector
      if(ncol(varvalue) == 1 & all(!is.na(as.numeric(varvalue)))) {
        
        print('numerical column vector')
        
        modvalue <- as.numeric(varvalue)
        
        eval(parse(text = glue::glue('{var} <- modvalue')))
        
        next()
      }
      
      # If character column vector
      if(ncol(varvalue) == 1) {
        
        print('single column dataframe')
        
        modvalue <- as_tibble(varvalue)
        
        # Remove empty rows
        modvalue <- modvalue %>% filter(unlist(apply(modvalue, 1, function(x) !all(x == ''))))
        
        names(modvalue) <- varvalue[[1]]
        
        modvalue <- modvalue %>% slice(-1)
        
        if(all(!is.na(as.numeric(modvalue %>% pull(1))))) modvalue <- mutate_all(modvalue, as.numeric)
        
        eval(parse(text = glue::glue('{var} <- modvalue')))
        
        next()
      }
      
      # If numerical row vector
      if(nrow(varvalue) == 1 & all(!is.na(as.numeric(varvalue)))) {
        
        print('numerical row vector')
        
        modvalue <- varvalue
        
        eval(parse(text = glue::glue('{var} <- modvalue')))
        
        next()
      }
      
      # If character row vector
      if(nrow(varvalue) == 1) {
        
        print('character row vector')
        
        modvalue <- varvalue
        
        eval(parse(text = glue::glue('{var} <- modvalue')))
        
        next()
      }
      
      # If 2d numerical array
      if(nrow(varvalue) > 1 & ncol(varvalue) > 1 & all(apply(varvalue, 2, function(x) all(!is.na(as.numeric(x)))))) {
        
        print('2d numerical array')
        
        modvalue <- data.frame(varvalue, stringsAsFactors = F)
        
        names(modvalue) <- NULL
        
        modvalue <- data.matrix(modvalue)
        
        eval(parse(text = glue::glue('{var} <- modvalue')))
        
        next()
      }
      
      # If dataframe with column names
      if(nrow(varvalue) > 1 & ncol(varvalue) > 1 & all(is.na(as.numeric(varvalue[1,])))) {
        
        print('dataframe')
        
        modvalue <- as_tibble(varvalue)
        
        # Remove empty columns
        modvalue <- modvalue %>% select_if(function(x) !all(x == ''))
        
        # Remove empty rows
        modvalue <- modvalue %>% filter(unlist(apply(modvalue, 1, function(x) !all(x == ''))))
        
        names(modvalue) <- modvalue %>% slice(1) %>% unlist() %>% as.character()
        
        modvalue <- modvalue %>% slice(-1)
        
        # Transform numeric columns to numeric instead of character or factor.
        modvalue <- modvalue %>% mutate_if(.predicate = {function(x) all(!is.na(as.numeric(x)))}, as.numeric)
        
        eval(parse(text = glue::glue('{var} <- modvalue')))
        
        next()
      }
      
      print('something else')
      
      modvalue <- varvalue
      
      eval(parse(text = glue::glue('{var} <- modvalue')))
    }
    
    # Variables can be used in this statement.
    eval(parse(text = glue('results <- {rscript}')))
    
    # If single value
    if(is.null(nrow(results))){
      
      return(results)
    }
    
    # If column vector
    if(is.null(ncol(results))){
      
      results <- results %>% matrix()
      
      return(results)
    } 
    
    # If dataframe with column names
    if(!is.null(names(results))){
      
      # Move column names to first row and convert to matrix.
      results <- bind_rows(results %>% slice(1), results)
      
      results[1,] <- names(results)
      
      names(results) <- NULL
      
      results <- results %>% as.matrix()
      
      return(results)
    }
    
    # Otherwise...
    return(results)
    
  }, error = function(e) {return(e)})
  
  return(glue::glue("Error: {err$message}"))
}
