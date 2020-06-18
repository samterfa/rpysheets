
# Swagger docs at ...s/__swagger__/ (needs trailing slash!)
if(Sys.getenv('PORT') == '') Sys.setenv(PORT = 8000)

#' @apiTitle R Google Sheets Formulas
#' @apiDescription These endpoints allow the user to create custom functions in Google spreadsheets which call R functions.

#* Return the product of 2 matrices
#* @param var1 An array of values representing the first matrix.
#* @param var2 An array of values representing the second matrix.
#* @post /myCustomFunction/
function(var1, var2){
  
  err <- tryCatch({
    
    return(data.matrix(var1) %*% data.matrix(var2))
    
  }, error = function(e) e)
  
  paste0('Error: ', err$message)
}

#* Confirmation Message
#* @get /
function(msg=""){
  "My API Deployed!"
}

