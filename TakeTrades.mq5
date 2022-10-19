#include<Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|                                                 MLTradeTaker.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
CPositionInfo  m_position;
CTrade tradeT;
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

ENUM_TIMEFRAMES times[] = {PERIOD_M1,PERIOD_M5,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_H6,PERIOD_H8};
int Barcount = 0;
void OnTick()
  {
//---
         if(Barcount<Bars(_Symbol,PERIOD_M15)){
             Sleep(30000);
             for(int i=PositionsTotal()-1;i>=0;i--){ 
                     if(m_position.SelectByIndex(i)){
                        tradeT.PositionClose(m_position.Ticket(),ULONG_MAX);
                     }
             }
             
            int file_handle=FileOpen("PatternData.txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON);
            for(int x=0;x<10;x++){
               string signal = FileReadString(file_handle);
               string symbol[];
               StringSplit(signal,StringGetCharacter("=",0),symbol);
               Print(ArraySize(symbol));
               Print("Symbol: "+symbol[0]);
               string powerArr[];
               StringSplit(signal,StringGetCharacter(" ",0),powerArr);
               double power = StringToDouble(powerArr[1]);
               Print("Power: "+power);
               
               if(power > 0){
                  OpenBuy(power,symbol[0]);
               }
               if(power < 0){
                  power = power*-1;
                  OpenSell(power,symbol[0]);
               }
               
            }
            FileClose(file_handle);
            Barcount = Bars(_Symbol,PERIOD_M15);
         }
         
}
         
void OpenBuy(double LotSize,string symbol){
       
      Print("Buying");
      tradeT.Buy(LotSize/1000,symbol+".lmx",0,0,0,"Buy");
      //barOpened = Bars(_Symbol,_Period);
      
   
}
void OpenSell(double LotSize,string symbol){
      Print("Selling");
      tradeT.Sell(LotSize/1000,symbol+".lmx",0,0,0,"Sell");
      //barOpened = Bars(_Symbol,_Period);
      
   
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
