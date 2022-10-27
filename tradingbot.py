import datetime
class Trade():
    def __init__(self,symbol,SL,TP,direction,tradeOpen):
        self.active = True
        self.timeOpen = datetime.datetime.now()
        self.timeClose = None
        self.symbol = symbol
        self.SL  =  float(SL)
        self.TP  =  float(TP)
        self.direction = direction
        self.open = float(tradeOpen)
        self.PL = 0
        self.pips = 0
    def tpHit(self) -> str:
        self.timeClose = datetime.datetime.now()
        self.active = False
    def slHit(self) -> str:
        self.timeClose = datetime.datetime.now()
        self.active = False

import requests
import time
import dill
import MLclassifier
from forex_python.converter import CurrencyRates
theroreticalCapital = 10000
class classifier:
    def __init__(self) -> None:
        self.botToken = '5302796495:AAHgGwNVakRgMLeauCQvdI4FY5ULbZlv-_c'
        self.url = 'https://api.telegram.org/bot'+self.botToken+'/'
        self.chatid = -1001854943641
        self.firstRun = True
        self.c = CurrencyRates()
        try:
            self.tradelist = dill.load(open("trades.pkl","rb"))
        except:
            self.tradelist = []
        while(True):
        #Daily Summary
            if(self.marketHours() and datetime.datetime.now().hour == 5 and datetime.datetime.now().minute == 0):
                self.dailySummary()
            #Market Open
            if(datetime.datetime.now().weekday()==6 and datetime.datetime.now().hour == 17 and datetime.datetime.now().minute == 0):
                message = "-------Market Open!-------"
                requests.get(self.url+'sendMessage?chat_id='+str(self.chatid)+'&text='+message)
            #End of Market
            if(datetime.datetime.now().weekday()==4 and datetime.datetime.now().hour == 17 and datetime.datetime.now().minute == 0):
                self.weeklySummary()
                time.sleep(60)
            #Reset Trigger List
            if(datetime.datetime.now().hour == 12 and datetime.datetime.now().minute == 0):
                print('12pm')
                #triggerList = []
            #Ran every 15 minutes check current candlestick patterns
            if(self.marketHours() and datetime.datetime.now().minute%15==0 or self.firstRun):
                self.checkTrades()
                print("Running Scan")
                triggers = MLclassifier.run()
                for s in triggers:
                    
                    if(self.checkActive(s)):
                        continue
                    if(len(triggers[s])>0):
                        currentPrice = self.getCurrentPrice(s)
                        if(triggers[s]=="BUY"):
                            self.tradelist.append(Trade(s,currentPrice-currentPrice*.0025,currentPrice+currentPrice*.0025,"BUY",currentPrice))
                            message = "Enter "+triggers[s]+" On "+s+"\n TP: "+str(round(currentPrice+currentPrice*.0025,6))+"✔️\n C: "+str(currentPrice)+"\n SL:"+str(round(currentPrice-currentPrice*.0025,6))+"❌"
                            requests.get(self.url+'sendMessage?chat_id='+str(self.chatid)+'&text='+message)
                        if(triggers[s]=="SELL"):
                            self.tradelist.append(Trade(s,currentPrice+currentPrice*.0025,currentPrice-currentPrice*.0025,"SELL",currentPrice))
                            message = "Enter "+triggers[s]+" On "+s+"\n TP: "+str(round(currentPrice-currentPrice*.0025,6))+"✔️\n C: "+str(currentPrice)+"\n SL:"+str(round(currentPrice+currentPrice*.0025,6))+"❌"
                            requests.get(self.url+'sendMessage?chat_id='+str(self.chatid)+'&text='+message)
                dill.dump(self.tradelist,open("trades.pkl","wb"))
                print("Finished Scan")
                self.firstRun = False
            else:
                time.sleep(60)
    def checkActive(self,symbol)->bool:
        for trade in self.tradelist:
            if(trade.active and trade.symbol == symbol):
                return True
        return False
    #Prevents calls from being made during off market hours
    def marketHours(self) -> bool:
        if((datetime.datetime.now().weekday()==4 and datetime.datetime.now().hour > 17) or datetime.datetime.now().weekday()==5 or datetime.datetime.now().weekday()==6 and datetime.datetime.now().hour < 17):
            return False
        return True
    


    def checkTrades(self):
        global theroreticalCapital
        print("Checking Trades")
        for trade in self.tradelist:
            if(trade.active):
                currentPrice = self.getCurrentPrice(trade.symbol)

                trade.PL = ((currentPrice/float(trade.open))-1)*100
                if((currentPrice>float(trade.TP) and trade.direction == "BUY") or (currentPrice<float(trade.TP) and trade.direction == "SELL")):
                    trade.tpHit()
                    trade.PL = abs(trade.TP)
                    print(trade.symbol)
                    print("Current: "+str(currentPrice))
                    print("TP: "+str(trade.TP))
                    message = "💸💸💸"+trade.symbol + " Hit TakeProfit for "+str(round(trade.PL,2))+"% 💸💸💸"
                    
                    theroreticalCapital = theroreticalCapital + ((theroreticalCapital*.05) * (trade.PL/100))
                    dill.dump(theroreticalCapital,open("capital.pkl","wb"))
                    message += "\n Theroretical Capital: $"+str(round(theroreticalCapital,2))
                    message += "\n Time Held: "+str(round((trade.timeClose - trade.timeOpen).seconds/3600,2)) + " Hours ⏰"
                    requests.get(self.url+'sendMessage?chat_id='+str(self.chatid)+'&text='+message)
                elif((currentPrice<float(trade.SL) and trade.direction == "BUY") or (currentPrice>float(trade.SL) and trade.direction == "SELL")):
                    trade.slHit()
                    print(trade.symbol)
                    print("Current: "+str(currentPrice))
                    print("SL: "+str(trade.SL))

                    trade.PL = -abs(trade.TP)
                    message = "🔻🔻🔻 "+trade.symbol + " Hit StopLoss for "+str(round(trade.PL,2))+"% 🔻🔻🔻"
                    
                    theroreticalCapital = theroreticalCapital + ((theroreticalCapital*.05) * (trade.PL/100))
                    dill.dump(theroreticalCapital,open("capital.pkl","wb"))
                    message += "\n Theroretical Capital: $"+str(round(theroreticalCapital,2))
                    message += "\n Time Held: "+str(round((trade.timeClose - trade.timeOpen).seconds/3600,2)) + " Hours"
                    print(currentPrice)
                    print(trade.SL)
                    requests.get(self.url+'sendMessage?chat_id='+str(self.chatid)+'&text='+message)
    def dailySummary(self) -> None:
        message = ""
        for trade in self.tradelist:
                if(trade.active):
                    message += trade.symbol +" "+trade.direction + " : "+str(round(float(trade.PL),2))+"% \n"
        requests.get(self.url+'sendMessage?chat_id='+str(self.chatid)+'&text='+message)
        try:
            winCount = 0
            lossCount = 0
            totalPips = 0
            unrealizedTrades = 0
            unrealizedProfit = 0
            for trade in self.tradelist:
                if(not trade.active and trade.timeClose > datetime.datetime.now() - datetime.timedelta(days=1)):
                    if(trade.PL<0):
                        lossCount+=1
                    else:
                        winCount+=1
                    totalPips += trade.PL
                if(trade.active):
                    unrealizedTrades += 1
                    unrealizedProfit += trade.PL

            message =  "           Daily Summary           \n Total Loosers: "+str(lossCount)+"\n Total Winners:  "+str(winCount)+"\n Win Rate: "+str(round(winCount/(lossCount+winCount),2))+"\n Total Profit: "+str(round(totalPips))+"\n Open Trades: "+str(unrealizedTrades)+"\n Fear Greed Index: "+str(fgi())+"\n Unrealized: "+str(round(unrealizedProfit,2)+"%")
            requests.get(self.url+'sendMessage?chat_id='+str(self.chatid)+'&text='+message)
            
            
            
        except:
            print("No Trades")
            
    def weeklySummary(self) -> None:
        try:
            winCount = 0
            lossCount = 0
            totalPips = 0
            unrealizedTrades = 0
            unrealizedProfit = 0
            for trade in self.tradelist:
                if(not trade.active and trade.timeClose > datetime.datetime.now() - datetime.timedelta(days=5)):
                    if(trade.PL<0):
                        lossCount+=1
                    else:
                        winCount+=1
                    totalPips += trade.PL
                if(trade.active):
                    unrealizedTrades += 1
                    unrealizedProfit += trade.PL

            message =  "           Weekly Summary           \n Total Loosers: "+str(lossCount)+"\n Total Winners:  "+str(winCount)+"\n Win Rate: "+str(round(winCount/(lossCount+winCount),2))+"\n Total Pips: "+str(round(totalPips))+"\n Open Trades: "+str(unrealizedTrades)+"\n Unrealized: "+str(unrealizedProfit)
            requests.get(self.url+'sendMessage?chat_id='+str(self.chatid)+'&text='+message)
        except:
            print("No Trades")
    def getCurrentPrice(self, symbol) -> float:
        #print(symbol)
        time.sleep(1)
        try:
            currentRate = self.c.get_rate(symbol[0:3],symbol[3:6])
        except:
            time.sleep(10)
            currentRate = self.c.get_rate(symbol[0:3],symbol[3:6])
        return currentRate

classifier()