/**
 * Run an R, Python, or other language script on spreadsheet data.
 *
 * @param var1 The value or cell contents to pass to your API.
 * @param var2 The value or cell contents to pass to your API.
 * @return The results of the API call you're about to make.
 * @customfunction
 */
function myCustomFunction(var1 = null, var2 = null){
  
  // Assuming your API endpoint is like {baseURL}/{endpoint}.
  var baseURL = '(Copy and paste your API base url here.)';
  var endpoint = 'myCustomFunction';
  
  // Encode the variable values as JSON (or XML, or something else). 
  // See Google Apps Script UrlFetchApp documentation.
  var data = {
    'var1': var1,
    'var2': var2,
  }
// Set up the API call. Use POST requests to pass variables.
// You can pass variables as query params of GET requests instead.
  var options = {
    'method' : 'post',
    'contentType': 'application/json',
    'payload' : JSON.stringify(data)
  };
  
  // Make the API call. NOTE: Trailing slashes are important!
  var response = UrlFetchApp.fetch(baseURL + '/' + endpoint + '/', options);
  
  // Parse the response.
  data = JSON.parse(response.getContentText());
 
  // I return "Error: {the error}" on script errors. This is 
  // not necessary, but it shows useful error messages in cells.
  if(String(data).substring(0,6) == "Error:"){
    throw(String(data));
  }
 
  return(data);
}