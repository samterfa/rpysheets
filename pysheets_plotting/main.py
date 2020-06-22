from fastapi import Body, FastAPI
from pydantic import BaseModel, Field
from typing import Optional, Union
import io
from starlette.responses import StreamingResponse

app = FastAPI()

class Pyscript(BaseModel):
    pyscript: str
    a: Optional[Union[list, str]] = None
    b: Optional[Union[list, str]] = None
    c: Optional[Union[list, str]] = None
    d: Optional[Union[list, str]] = None
    e: Optional[Union[list, str]] = None

def is_number(s):
    try:
        complex(s) # for int, long, float and complex
    except ValueError:
        return False

    return True

@app.post("/pyscript")
def run_pyscript(args: Pyscript):
  
  import sys
  
  try:
    
    global np
    global pd
    
    import numpy as np
    import pandas as pd
    
    # Gather non-null a - e variables as vars.
    # Parse a - e converting from list to the intended Python data type.
    global arguments, a, b, c, d, e, results
    
    arguments = args
    
    varstrings = ['a', 'b', 'c', 'd', 'e']
    
    for var in varstrings:
     
      exec(var + ' = arguments.' + var, globals())
      
      if(eval(var, globals()) is None):
        
        continue
      
      # If single value
      if(eval('type(' + var + ') == str')): 
       
        print('Single Value') 
       
        continue
     
      if(eval('type(' + var + ') == list')):
         
        exec(var + '= pd.DataFrame(' + var + ')', globals())
        
        # If row 1 of incoming data are all strings, treat them as column headers of DataFrame.
        if eval('np.array([not is_number(' + var + '[col][0]) for col in ' + var + ']).all()', globals()):
          
          print('Data Frame with column names')
          
          exec('colnames = list(' + var + '.iloc[0])', globals())
          exec(var + ' = ' + var + '.drop(0)', globals())
          exec(var + '= pd.DataFrame(' + var + ')', globals())
          exec(var + '.columns = colnames', globals())
          exec('colsAreNumeric = [np.array([is_number(val) for val in ' + var + '[col]]).all() for col in ' + var + ']', globals())
          exec('numericCols = [' + var + '.columns[i] for i, x in enumerate(colsAreNumeric) if x]', globals())
          exec('for col in numericCols: ' + var + '[col] = ' + var + '[col].astype(float)', globals())
          
        else:
          
          print('Data Frame with no column names')
        
          exec('colsAreNumeric = [np.array([is_number(val) for val in ' + var + '[col]]).all() for col in ' + var + ']', globals())
          exec('numericCols = [' + var + '.columns[i] for i, x in enumerate(colsAreNumeric) if x]', globals())
          exec('for col in numericCols: ' + var + '[col] = ' + var + '[col].astype(float)', globals())
        
        continue
     
    exec(args.pyscript, globals())
    
    # If results is a dataframe with column names
    if hasattr(results, 'columns'):
      
      # Check if column names are simply 0 - ncol. These would be dummy column names added when cast to DataFrame.
      if not np.array([str(enum[0]) == str(enum[1]) for enum in list(enumerate(list(results.columns)))]).all():
      
        print('Returning Data Frame with Column Names')
        
        # Add column names as 1st row and append results.
        results = pd.DataFrame(np.array(list(results.columns)).reshape(1,len(list(results.columns))), columns = list(results.columns)).append(results)
        
        results = np.array(results).tolist()
        
    if hasattr(results, 'shape'):
    
      print('Returning Array')
      
      results = np.array(results).tolist()
      
    return results
      
  except: # catch *all* exceptions
    e_type, e_value, e_traceback = sys.exc_info()
    
    return 'Error: ' + str(e_type) + ' ' + str(e_value)


@app.post("/pyplot")
def run_pyplot(args: Pyscript):
  
  def uploadToImgur(filepath):

    import base64
    import json
    import requests
    
    from base64 import b64encode
    
    with open('.creds/imgur.json') as f:
      client_id = json.load(f)['clientID']
    
    headers = eval('{"Authorization": "Client-ID ' + client_id + '"}')
  
    url = "https://api.imgur.com/3/upload"
    
    j1 = requests.post(
        url, 
        headers = headers,
        data = {
            'image': b64encode(open(filepath, 'rb').read()),
            'type': 'base64'
            }
        )
    
    data = json.loads(j1.text)['data']
    
    return data['link']

  results = run_pyscript(args)
  
  import os
  files = os.listdir()
  
  toUpload = [files[i] for i in [i[0] for i in enumerate([file.find('.png') > 0 for file in files]) if i[1]]]

  if(len(toUpload) > 0):
    
    return uploadToImgur(toUpload[0])

  else:
    
    return 'No Image Found to Upload'

@app.get("/")
def myProjectDeployed():
  
  return "My Project Deployed!"
