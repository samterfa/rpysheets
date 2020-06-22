apifunction <- function(rscript, a = NULL, b = NULL, c = NULL, d = NULL, e = NULL, imgurClientID = NULL){  
  
  require(dplyr)
  require(stringr)
  require(purrr)
  require(glue)
  
  if(str_detect(rscript, 'ggplot')) require(ggplot2)
  
  # Gather non-null a - e variables as vars.
  vars <- as.list(environment()) %>% compact() 
  
  # Parse a - e converting from matrix to the intended R data type.
  for(var in names(vars)[!names(vars) %in% c('rscript', 'imgurClientID')]){
    
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
  
  # Run rscript with R-interpreted variables a - e.
  eval(parse(text = glue('results <- {rscript}')))
  
  # If single value...
  if(is.null(nrow(results))){
    
    return(results)
  }
  
  # If column vector...
  if(is.null(ncol(results))){
    
    results <- results %>% matrix()
    
    return(results)
  } 
  
  # If dataframe with column names...
  if(!is.null(names(results))){
    
    # Move column names to first row and convert to matrix.
    
    results <- results %>% mutate_all(as.character)
    
    results <- bind_rows(results %>% slice(1), results)
    
    results[1,] <- names(results)
    
    names(results) <- NULL
    
    results <- results %>% as.matrix()
    
    return(results)
  }
  
  # Otherwise...
  return(results)
}