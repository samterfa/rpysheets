var rApiURL = "{R_GoogleCloudRunAppURL}";

/**
 * Run an R script on spreadsheet data
 *
 * @param rscript The R script to run.
 * @param a A variable to pass into the rscript. It can be a value or cell reference.
 * @param b A variable to pass into the rscript. It can be a value or cell reference.
 * @param c A variable to pass into the rscript. It can be a value or cell reference.
 * @param d A variable to pass into the rscript. It can be a value or cell reference.
 * @param e A variable to pass into the rscript. It can be a value or cell reference.
 * @return The URL of an R plot.
 * @customfunction
 */
function rplot(rscript, a = null, b = null, c = null, d = null, e = null){

  var endpoint = "rplot";
  
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

  var response = UrlFetchApp.fetch(rApiURL + '/' + endpoint, options);
  
  data = JSON.parse(response.getContentText());

  if(String(data).substring(0,6) == "Error:"){
    throw(String(data));
  }
  
  return(data);
}

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

  var response = UrlFetchApp.fetch(rApiURL + '/' + endpoint, options);

  data = JSON.parse(response.getContentText());

  if(String(data).substring(0,6) == "Error:"){
    throw(String(data));
  }
  
  return(data);
}