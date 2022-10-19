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
void OnTick()
  {
//---
   for(int t=0;t<ArraySize(times)-1;t++){
     for(int x=0;x<SymbolsTotal(1);x++){
        string symbol = SymbolName(x,1);
        Comment(symbol+EnumToString(times[t]));
        int file_handle=FileOpen("Data"+symbol+EnumToString(times[t])+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON);
        int file_handle2=FileOpen("signal"+symbol+EnumToString(times[t])+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON);
         double ma = iMA(symbol,times[t],50,0,MODE_SMA,PRICE_CLOSE);
         double bb = iBands(symbol,times[t],50,0,2,PRICE_CLOSE);
         double bandArrUpper[];
         double bandArrLower[];
         double bandArrBase[];
         double movingAvgArr[];
         CopyBuffer(bb,1,0,2,bandArrUpper);
         CopyBuffer(bb,2,0,2,bandArrLower);
         CopyBuffer(bb,0,0,2,bandArrBase);
         CopyBuffer(ma,0,0,2,movingAvgArr);
            double BarClose = iClose(symbol,times[t],1);
            double BarOpen = iOpen(symbol,times[t],1);
            double Volume = iVolume(symbol,times[t],1);
            double BarLength = MathRound((BarClose-BarOpen)*1000000000000);
            double TopBand = bandArrUpper[1];
            double LowerBand = bandArrLower[1];
            double BaseBand = bandArrBase[1];
            double MA5 = movingAvgArr[1];        
         string toprint=(DoubleToString(BarClose,8)+","+DoubleToString(BarOpen,8)+","+DoubleToString(BarLength,8)+","+DoubleToString(MA5)+","+DoubleToString(TopBand,8)+","+DoubleToString(BaseBand,8)+","+DoubleToString(LowerBand,8));
         FileWrite(file_handle,toprint);
         string signal = FileReadString(file_handle2);
         //Print(signal);
         if(signal == "buy"){
            OpenBuy(2,symbol);
            FileWrite(file_handle2,"Trade Taken");
         }
         if(signal == "sell"){
            OpenSell(2,symbol);
            FileWrite(file_handle2,"Trade Taken");
         }
         FileClose(file_handle);
         FileClose(file_handle2);
     }}
         
  }
void OpenBuy(double LotSize,string symbol){
      Print("Buying");
      if(!PositionSelect(symbol)){
        tradeT.Buy(1,symbol,0,SymbolInfoDouble(symbol,SYMBOL_BID)-SymbolInfoDouble(symbol,SYMBOL_POINT)*(25*10),SymbolInfoDouble(symbol,SYMBOL_ASK)+SymbolInfoDouble(symbol,SYMBOL_POINT)*(25*10),"Buy");
      }
      //barOpened = Bars(_Symbol,_Period);
      
   
}
void OpenSell(double LotSize,string symbol){
      Print("Selling");
      if(!PositionSelect(symbol)){
        tradeT.Sell(1,symbol,0,SymbolInfoDouble(symbol,SYMBOL_ASK)+SymbolInfoDouble(symbol,SYMBOL_POINT)*(25*10),SymbolInfoDouble(symbol,SYMBOL_BID)-SymbolInfoDouble(symbol,SYMBOL_POINT)*(25*10),"Sell");
      }
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
