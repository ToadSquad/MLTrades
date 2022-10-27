import my_filedata2


import yfinance
from sklearn import datasets
from sklearn import tree
from sklearn import svm
from sklearn.model_selection import train_test_split as tts
import my_filedata2
import time
from forex_python.converter import CurrencyRates
def run():
    symbols = ['EURUSD','USDCHF','GBPUSD','USDJPY','USDCAD','EURAUD','EURCHF','EURJPY','AUDUSD','GBPCHF','CADJPY','GBPJPY','AUDNZD','AUDCAD','AUDCHF','EURGBP','EURAUD','EURCHF','CHFJPY','AUDJPY','EURNZD','EURCAD','CADCHF','NZDJPY','NZDUSD']
    timeframes = ['PERIOD_M1']#,'PERIOD_M5','PERIOD_M10','PERIOD_M12','PERIOD_M15','PERIOD_M20','PERIOD_M30','PERIOD_H1','PERIOD_H4','PERIOD_H6','PERIOD_H8']
    triggers = {}
    c = CurrencyRates()
    for s in symbols:
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

                    x=0
                    count=0
                    
                    
                    train_feats, test_feats, train_labels, test_labels = tts(features, labels, test_size=0.2)
                        
                        #clf = svm.SVC()
                    clf = tree.DecisionTreeClassifier()
                        
                        #train
                        
                        
                    try:
                        time.sleep(1)
                        currentClose = c.get_rate(s[0:3],s[3:6])
                    except:
                        time.sleep(10)
                        currentClose = c.get_rate(s[0:3],s[3:6]) 
                    test_feats = [[currentClose]]
                    while(x<10):
                        #predictions
                        clf.fit(train_feats, train_labels)
                        predictions.append(clf.predict(test_feats))
                        x = x+1
                        
                            
                        
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

                    if(countBuy>=6):
                        triggers[s] = "BUY"
                    elif(countSell>=6):
                        triggers[s] = "SELL"
    return triggers
                    
                    