#include<Trade\Trade.mqh>
#property copyright "Justin Parker"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int file_handle;
int file_handle2;
int file_handle3;
int file_handle4;
CTrade tradeT;
int OnInit(){
      getData();
   
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
int BarsCount = 0;
int tradedBar;
int ticket;
string signal;
int length = 10;
int tradelength = 240;
bool zero = true;
int baramount = 10000;//Bars(_Symbol,PERIOD_CURRENT)-200;
bool trade = true;
string datafile = "Data"+Symbol()+".txt";
void OnTick()
  {
//---
   Comment(Bars(_Symbol,PERIOD_CURRENT));
   
   if(Bars(_Symbol,PERIOD_CURRENT)>BarsCount){
 
   
      Sleep(3000);
      string datafile = "Data"+Symbol()+".txt";
      FileOpen(datafile,FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON);
      FileOpen("signal"+Symbol()+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON);
      FileOpen("signalPower"+Symbol()+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON);
      
      
      /*
      NEW PARAMATERS
      */
      double ma = iMA(_Symbol,PERIOD_CURRENT,50,0,MODE_SMA,PRICE_CLOSE);
      double bb = iBands(Symbol(),PERIOD_CURRENT,50,0,2,PRICE_CLOSE);
      double bandArrUpper[];
      double bandArrLower[];
      double bandArrBase[];
      double movingAvgArr[];
      CopyBuffer(bb,1,0,1,bandArrUpper);
      CopyBuffer(bb,2,0,1,bandArrLower);
      CopyBuffer(bb,0,0,1,bandArrBase);
      CopyBuffer(ma,0,0,1,movingAvgArr);
      double BarClose = iClose(_Symbol,PERIOD_CURRENT,0);
      double BarOpen = iOpen(_Symbol,PERIOD_CURRENT,0);
      double Volume = iVolume(_Symbol,PERIOD_CURRENT,0);
      double BarLength = MathRound((BarClose-BarOpen)*1000000000000);
      double TopBand = bandArrUpper[0];
      double LowerBand = bandArrLower[0];
      double BaseBand = bandArrBase[0];
      double MA5 = movingAvgArr[0];
      int Result =0;
    
      string toprint=(DoubleToString(BarClose,8)+","+DoubleToString(BarOpen,8)+","+DoubleToString(BarLength,8)+","+DoubleToString(MA5)+","+DoubleToString(TopBand,8)+","+DoubleToString(BaseBand,8)+","+DoubleToString(LowerBand,8));
     
      FileWrite(file_handle,toprint);
      Comment(toprint);
   
      signal = FileReadString(file_handle2);
      double tradingLot = .1;
      tradingLot = StringToDouble(FileReadString(file_handle4,-1)); 
      double takenTradingLot;
      trade = true;
      for(int x=0;x<PositionsTotal();x++){
         if(PositionGetSymbol(x)==Symbol()){
            trade = false;
            break;
         }
      }
     /* if(trade==false){
         if(MathAbs(tradedBar-Bars(_Symbol,PERIOD_CURRENT))>=tradelength){
            Comment((tradedBar-Bars(_Symbol,PERIOD_CURRENT)));
            OrderSelect(ticket,SELECT_BY_TICKET);
            Comment(OrderType()==OP_BUY);
            if((signal=="sell"&&OrderType()==OP_BUY)||(signal=="buy"&&OrderType()==OP_SELL)){
               OrderClose(ticket,takenTradingLot,Ask,3,clrNONE);
            }
         }
      
      }*/
      if(trade){
         double ask = NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_ASK),_Digits);
         double bid = NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_BID),_Digits);
         if(signal=="buy"){
            Comment("BUYING");
            double spread = ask-bid;
            tradeT.Buy(tradingLot,_Symbol,ask,bid-(_Point*length),ask+(_Point*length),"Buy");
            takenTradingLot = tradingLot;
            tradedBar = Bars(_Symbol,PERIOD_CURRENT); 
         }
         else if(signal == "sell"){
            Comment("SELLING");
            double spread = ask-bid;
            tradeT.Sell(tradingLot,_Symbol,bid,ask+(_Point*length),bid-(_Point*length),"Sell");
            takenTradingLot = tradingLot;
            tradedBar = Bars(_Symbol,PERIOD_CURRENT);
       
         }
      }
        BarsCount = Bars(_Symbol,PERIOD_CURRENT);
     FileClose(file_handle);
     FileClose(file_handle2); 
     FileClose(file_handle4);
}
  
  FileClose(file_handle4);
  FileClose(file_handle);
  FileClose(file_handle2);  

}
  
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+ 
void getData(){
  FileDelete("DataOld"+Symbol()+".txt");
  file_handle=FileOpen("Data"+Symbol()+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON);
  file_handle2=FileOpen("signal"+Symbol()+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON);
  file_handle3=FileOpen("DataOld"+Symbol()+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON);
  file_handle4=FileOpen("signalPower"+Symbol()+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON);
  double ask = NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_ASK),_Digits);
  double bid = NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_BID),_Digits);
  
  double spread = MathAbs(ask-bid);
   int Result;
   double ma = iMA(_Symbol,PERIOD_CURRENT,50,0,MODE_SMA,PRICE_CLOSE);
   double bb = iBands(Symbol(),PERIOD_CURRENT,50,0,2,PRICE_CLOSE);
   double bandArrUpper[];
   double bandArrLower[];
   double bandArrBase[];
   double movingAvgArr[];
   CopyBuffer(bb,1,0,baramount,bandArrUpper);
   CopyBuffer(bb,2,0,baramount,bandArrLower);
   CopyBuffer(bb,0,0,baramount,bandArrBase);
   CopyBuffer(ma,0,0,baramount,movingAvgArr);
   for(int x=tradelength;x<baramount;x++){
      /*
      NEW PARAMATERS
      */
      double BarClose = iClose(_Symbol,PERIOD_CURRENT,x);
      double BarOpen = iOpen(_Symbol,PERIOD_CURRENT,x);
      double Volume = iVolume(_Symbol,PERIOD_CURRENT,x);
      double BarLength = MathRound((BarClose-BarOpen)*1000000000000);
      double TopBand = bandArrUpper[x];
      double LowerBand = bandArrLower[x];
      double BaseBand = bandArrBase[x];
      double MA5 = movingAvgArr[x];
      Result =0;
      for(int z=1;z<tradelength+1;z++){
         if((Result ==0)){
            if(iLow(_Symbol,PERIOD_CURRENT,x-z)<=((BarClose-spread)-(_Point*length))){
               Result = -1;
               break;
         }
         else if(iHigh(_Symbol,PERIOD_CURRENT,x-z)>=((BarClose+spread)+(_Point*length))){
            Result = 1;
            break;
         }
         else{
            Result = 0;
         }
         }
      }
      if(!zero){
         if(Result==0){
            if(iClose(_Symbol,PERIOD_CURRENT,x-5)>BarClose){
               Result = 1;
            }
            else{
               Result = -1;
            }
         }
   }
   
   string toprint=(DoubleToString(BarClose,8)+","+DoubleToString(BarOpen,8)+","+DoubleToString(BarLength,8)+","+DoubleToString(MA5)+","+DoubleToString(TopBand,8)+","+DoubleToString(BaseBand,8)+","+DoubleToString(LowerBand,8)+","+Result);
   int test = StringReplace(toprint,",",",");
   if(!(test<7)){
      FileWrite(file_handle3,toprint);
   }
   }
   FileClose(file_handle4);
   FileClose(file_handle3);
   FileClose(file_handle2);
   FileClose(file_handle);


}