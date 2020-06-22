var pyApiURL = "{Py_GoogleCloudRunAppURL}";

/**
 * Run an Python script on spreadsheet data
 *
 * @param pyscript The Python script to run.
 * @param a A variable to pass into the pyscript. It can be a value or cell reference.
 * @param b A variable to pass into the pyscript. It can be a value or cell reference.
 * @param c A variable to pass into the pyscript. It can be a value or cell reference.
 * @param d A variable to pass into the pyscript. It can be a value or cell reference.
 * @param e A variable to pass into the pyscript. It can be a value or cell reference.
 * @return The URL of a Python plot.
 * @customfunction
 */
function pyplot(pyscript, a = null, b = null, c = null, d = null, e = null){

  var endpoint = "pyplot";
  
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

  var response = UrlFetchApp.fetch(pyApiURL + '/' + endpoint, options);
  
  data = JSON.parse(response.getContentText());

  if(String(data).substring(0,6) == "Error:"){
    throw(String(data));
  }
  
  return(data);
}

 /**
 * Run an Python script on spreadsheet data
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

  var response = UrlFetchApp.fetch(pyApiURL + '/' + endpoint, options);

  data = JSON.parse(response.getContentText());

  if(String(data).substring(0,6) == "Error:"){
    throw(String(data));
  }
  
  return(data);
}