//+------------------------------------------------------------------+
//|                                                SymbolGrabber.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   grabSymbols();
   Print("Symbols Grabbed");
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
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
ENUM_TIMEFRAMES times[] = {PERIOD_M1,PERIOD_M5,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_H6,PERIOD_H8};
void grabSymbols(){
   int file_handle=FileOpen("symbols.txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON);
   for(int t=0;t<ArraySize(times);t++){
     for(int x=0;x<SymbolsTotal(1);x++){ 
     FileWrite(file_handle,SymbolName(x,1)+EnumToString(times[t]));
     }}
     
}
