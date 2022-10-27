import my_filedata2


import yfinance
from sklearn import datasets
from sklearn import tree
from sklearn import svm
from sklearn.model_selection import train_test_split as tts
import my_filedata2
import time
from forex_python.converter import CurrencyRates
import yfinance

import numpy as np
import matplotlib.pyplot as plt
def run():
    symbols = ['EURUSD','USDCHF','GBPUSD','USDJPY','USDCAD','EURAUD','EURCHF','EURJPY','AUDUSD','GBPCHF','CADJPY','GBPJPY','AUDNZD','AUDCAD','AUDCHF','EURGBP','EURAUD','EURCHF','CHFJPY','AUDJPY','EURNZD','EURCAD','CADCHF','NZDJPY','NZDUSD']
    timeframes = ['PERIOD_M1']#,'PERIOD_M5','PERIOD_M10','PERIOD_M12','PERIOD_M15','PERIOD_M20','PERIOD_M30','PERIOD_H1','PERIOD_H4','PERIOD_H6','PERIOD_H8']
    triggers = {}
    c = CurrencyRates()
    SLCount = 0
    TPCount = 0
    barnum = 0
    for s in symbols:
        historyData = yfinance.Ticker(s+"=X").history(period="2y",interval="1h")
        accuracy = []
        print("SL: "+str(SLCount))
        print("TP: "+str(TPCount))
        for x in range(len(historyData.Close)):
                    if(x<barnum):
                        continue
                    bar = historyData.Close[x]
                    
                    triggers[s] = ""
                    for t in timeframes:
                        #print(s+t)
                        file1 ='/Data/DataOld'+s+t+'.txt'
                        try:
                            mfd = my_filedata2.my_online(s+t)
                        except:
                            print(s+t+" FAILED")
                            continue
                        features = mfd[0]
                        labels = mfd[1]
                

                        predictions = []

                        
                        count=0
                        
                        
                        train_feats, test_feats, train_labels, test_labels = tts(features, labels, test_size=0.2)
                            
                            #clf = svm.SVC()
                        clf = tree.DecisionTreeClassifier()
                            
                            #train
                            
                            
                        currentClose = bar
                        test_feats = [[currentClose]]
                       
                            #predictions
                        clf.fit(train_feats, train_labels)
                        predictions.append(clf.predict(test_feats))
                            
                                
                            
                        #print(test_feats)
                        countBuy = 0
                        countSell =0
                        countZero =0
                        for pre in predictions:
                            if(pre == 1):
                                countBuy = countBuy+1
                            elif(pre == -1):
                                countSell = countSell+1
                            else:
                                countZero = countZero+1
                        takeProfit = 0
                        stopLoss = 0
                        if(countBuy>=1):
                            triggers[s] = "BUY"
                            print(historyData.Close.index[x])
                            takeProfit = currentClose+currentClose*.0025
                            stopLoss = currentClose-currentClose*.0025
                        elif(countSell>=1):
                            triggers[s] = "SELL"
                            print(historyData.Close.index[x])
                            takeProfit = currentClose-currentClose*.0025
                            stopLoss = currentClose+currentClose*.0025
                    #Get Result
                    
                    for num in range(x,len(historyData.Close)):
                        futureBar = historyData.Close[num]
                        if((triggers[s] == "SELL" and futureBar>stopLoss) or (triggers[s] == "BUY" and futureBar < stopLoss)):
                            SLCount += 1
                            accuracy.append(TPCount/(SLCount+TPCount))
                            barnum = x+num
                            break
                        elif((triggers[s] == "SELL" and futureBar<takeProfit) or (triggers[s] == "BUY" and futureBar > takeProfit)):
                            TPCount +=1
                            accuracy.append(TPCount/(SLCount+TPCount))
                            barnum = x+num
                            break
                    print("Total Accuracy: "+str(TPCount/(SLCount+TPCount)))
        print("Total Accuracy: "+str(TPCount/(SLCount+TPCount)))
        print("SL: "+str(SLCount))
        print("TP: "+str(TPCount))
        plt.plot(accuracy, color="red")
        return triggers
                    
run()