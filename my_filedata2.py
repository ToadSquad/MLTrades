"""
Created on Sat Oct 19 12:41:21 2019
@author: parkerj12
"""

import numpy as np
from shutil import copyfile
from io import StringIO
def my_online(symbol):
    # URL for the Pima Indians Diabetes dataset (UCI Machine Learning Repository)
    my_file = "C:/Users/parkerj12/AppData/Roaming/MetaQuotes/Terminal/Common/Files/DataOldCopy"+symbol+".txt"
    copyfile("C:/Users/parkerj12/AppData/Roaming/MetaQuotes/Terminal/Common/Files/DataOld"+symbol+".txt", my_file)
    #data = open(my_file,'r',encoding='UTF-16-LE').readlines()[:-1]
    data = ""
    file = open(my_file,'r',encoding='UTF-16-LE')
    for line in file.readlines():
        if(line.count(',')==7):
            data += line
    
    #for s in data:
        #print(s)
    #f= open(my_file,"r")
    # download the file
    #raw_data = f.read
    # load the CSV file as a numpy matrix
    
    dataset = np.genfromtxt(StringIO(data), delimiter=",",skip_header=1,missing_values="optional")
    print(dataset.shape)
            # separate the data from the target attributes
    x = dataset[:,0:5]
    y = dataset[:,5]
    return (x,y)