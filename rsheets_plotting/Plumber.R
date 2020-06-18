
# Swagger docs at ...s/__swagger__/ (needs trailing slash!)
if(Sys.getenv('PORT') == '') Sys.setenv(PORT = 8000)

#' @apiTitle R Google Sheets Formulas
#' @apiDescription These endpoints allow the user to create custom functions in Google spreadsheets which call R functions.

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
    
    # apifunctions/rscript.R actually contains the rscript code. This allows /rplot to reuse rscript code.
    source('apifunctions/rscript.R')
    
    # Run rscript as R code using eval(parse(text = ...))
    return(do.call(apifunction, as.list(environment())))
    
  }, error = function(e) {return(e)})
  
  # Return useful error message on error.
  return(glue::glue("Error: {err$message}"))
}

#* Generates, uploads, and returns a URL for a png image.
#* @param rscript The R script to run which results in an image.
#* @param a A variable to pass into the rscript.
#* @param b A variable to pass into the rscript.
#* @param c A variable to pass into the rscript.
#* @param d A variable to pass into the rscript.
#* @param e A variable to pass into the rscript.
#* @post /rplot
function(rscript, a, b, c, d, e){
  
  require(jsonlite)
  require(dplyr)
  require(httr)
  
  err <- tryCatch({
    
    # Read in imgur.com client ID. You can just set this manually here if you want.
    imgurClientID <- fromJSON('.creds/imgur.json')$clientID
    
    # Force rscript to generate a PNG image.
    rscript <- paste0('{png(file = "temp.png", bg = "white"); ', rscript, '; dev.off()}')
    
    # Run rscript as R code using eval(parse(text = ...))
    source('apifunctions/rscript.R')
    do.call(apifunction, as.list(environment()))
   
    # POST image to imgur.com.
    if(file.exists('temp.png')){
      res <- POST(url="https://api.imgur.com/3/upload", 
                  add_headers(Authorization=glue::glue('Client-ID {imgurClientID}')),
                  body=list(image=upload_file('temp.png')))
      file.remove('temp.png')
    }else{
      stop('rscript failed to produce an image.')
    }
    
    # Return the uploaded image's URL.
    url <- content(res)$data$link[[1]]
    
    return(url)
    
  }, error = function(e) e)
  
  # Return useful error message on error.
  return(glue::glue('Error: {err$message}'))
}
