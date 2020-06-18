from fastapi import FastAPI
from pydantic import BaseModel

class Matrices(BaseModel):
    var1: list
    var2: list
    
app = FastAPI()

@app.post("/myCustomFunction/")
def myCustomFunction(matrices: Matrices):
  
  import sys
  
  try:
    import numpy as np
    
    var1 = np.matrix(matrices.var1)
    var2 = np.matrix(matrices.var2)
    
    results = np.matmul(var1, var2)
    
    return np.array(results).tolist()
  
  except: # catch *all* exceptions
    e_type, e_value, e_traceback = sys.exc_info()
    
    return 'Error: ' + str(e_type) + ' ' + str(e_value)

@app.get("/")
def myProjectDeployed():
  
  return "My Project Deployed!"
