 /**
 * Run an R script on spreadsheet data
 *
 * @param rscript The R script to run.
 * @param a A variable to pass into the rscript. It can be a value or cell reference.
 * @param b A variable to pass into the rscript. It can be a value or cell reference.
 * @param c A variable to pass into the rscript. It can be a value or cell reference.
 * @param d A variable to pass into the rscript. It can be a value or cell reference.
 * @param e A variable to pass into the rscript. It can be a value or cell reference.
 * @return The results of the R script.
 * @customfunction
 */
function rscript(rscript, a = null, b = null, c = null, d = null, e = null){

  var apiURL = "YourAPIurl";
  var endpoint = "rscript";
  
  var data = {
    'rscript':rscript,
    'a':a,
    'b':b,
    'c':c,
    'd':d,
    'e':e
  }

  var options = {
    'method' : 'post',
    'contentType': 'application/json',
    'payload' : JSON.stringify(data)
  };

  var response = UrlFetchApp.fetch(apiURL + '/' + endpoint, options);

  data = JSON.parse(response.getContentText());

  if(String(data).substring(0,6) == "Error:"){
    throw(String(data));
  }
  
  return(data);
}

 /**
 * Run a Python script on spreadsheet data
 *
 * @param pyscript The Python script to run.
 * @param a A variable to pass into the pyscript. It can be a value or cell reference.
 * @param b A variable to pass into the pyscript. It can be a value or cell reference.
 * @param c A variable to pass into the pyscript. It can be a value or cell reference.
 * @param d A variable to pass into the pyscript. It can be a value or cell reference.
 * @param e A variable to pass into the pyscript. It can be a value or cell reference.
 * @return The results of the Python script.
 * @customfunction
 */
function pyscript(pyscript, a = null, b = null, c = null, d = null, e = null){

  var apiURL = "YourAPIurl";
  var endpoint = "pyscript";
  
  var data = {
    'pyscript':pyscript,
    'a':a,
    'b':b,
    'c':c,
    'd':d,
    'e':e
  }

  var options = {
    'method' : 'post',
    'contentType': 'application/json',
    'payload' : JSON.stringify(data)
  };

  var response = UrlFetchApp.fetch(apiURL + '/' + endpoint, options);

  data = JSON.parse(response.getContentText());

  if(String(data).substring(0,6) == "Error:"){
    throw(String(data));
  }

  return(data);
}


/**
 * Use a neural network to predict what number an image represents.
 *
 * @param imgURL The URL of the image to predict on.
 * @return The predicted digit that the picture represents.
 * @customfunction
 */
function mnist(imgURL){

  var apiURL = "YourAPIurl";
  var endpoint = "mnist";
  
  var data = {
    'imgURL':imgURL
  }

  var options = {
    'method' : 'post',
    'contentType': 'application/json',
    'payload' : JSON.stringify(data)
  };

  var response = UrlFetchApp.fetch(apiURL + '/' + endpoint, options);

  data = JSON.parse(response.getContentText());

  if(String(data).substring(0,6) == "Error:"){
    throw(String(data));
  }

  return(data);
}
