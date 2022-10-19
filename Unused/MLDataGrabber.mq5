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
      Print("Done getting Data");
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
input int length = 25; //Pips to target
input int tradelength = 240; //Bar length to reach target
bool zero = true;
input int baramount = 1000;//Bars(symbol,times[t])-200;
bool trade = true;
//string datafile = "Data"+symbol+".txt";
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
ENUM_TIMEFRAMES times[] = {PERIOD_M1,PERIOD_M5,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_H6,PERIOD_H8};//PERIOD_W1,PERIOD_MN1};
void getData(){
   int barcount = baramount;
   for(int t=0;t<ArraySize(times)-1;t++){
     for(int x=0;x<SymbolsTotal(1);x++){
        string symbol = SymbolName(x,1);
        FileDelete("DataOld"+symbol+".txt");
        if(baramount>Bars(symbol,times[t])){
            barcount = Bars(symbol,times[t]);
        }
        file_handle=FileOpen("Data"+symbol+EnumToString(times[t])+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON);
        file_handle2=FileOpen("signal"+symbol+EnumToString(times[t])+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON);
        file_handle3=FileOpen("DataOld"+symbol+EnumToString(times[t])+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON);
        file_handle4=FileOpen("signalPower"+symbol+EnumToString(times[t])+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON);
        double ask = NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_ASK),_Digits);
        double bid = NormalizeDouble(SymbolInfoDouble(symbol,SYMBOL_BID),_Digits);
        
         double spread = MathAbs(ask-bid);
         int Result;
         double ma = iMA(symbol,times[t],50,0,MODE_SMA,PRICE_CLOSE);
         double bb = iBands(symbol,times[t],50,0,2,PRICE_CLOSE);
         double bandArrUpper[];
         double bandArrLower[];
         double bandArrBase[];
         double movingAvgArr[];
         CopyBuffer(bb,1,0,barcount,bandArrUpper);
         CopyBuffer(bb,2,0,barcount,bandArrLower);
         CopyBuffer(bb,0,0,barcount,bandArrBase);
         CopyBuffer(ma,0,0,barcount,movingAvgArr);
         for(int x=tradelength;x<barcount;x++){
            /*
            NEW PARAMATERS
            */
            double BarClose = iClose(symbol,times[t],x);
            double BarOpen = iOpen(symbol,times[t],x);
            double Volume = iVolume(symbol,times[t],x);
            double BarLength = MathRound((BarClose-BarOpen)*1000000000000);
            double TopBand = bandArrUpper[x];
            double LowerBand = bandArrLower[x];
            double BaseBand = bandArrBase[x];
            double MA5 = movingAvgArr[x];
            Result =0;
            for(int z=1;z<tradelength+1;z++){
               if((Result ==0)){
                  if(iLow(symbol,times[t],x-z)<=((BarClose-spread)-(SymbolInfoDouble(symbol,SYMBOL_POINT)*length*10))){
                     Result = -1;
                     break;
               }
               else if(iHigh(symbol,times[t],x-z)>=((BarClose+spread)+(SymbolInfoDouble(symbol,SYMBOL_POINT)*length*10))){
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
                  if(iClose(symbol,times[t],x-5)>BarClose){
                     Result = 1;
                  }
                  else{
                     Result = -1;
                  }
               }
         }
         
         string toprint=(DoubleToString(BarClose,8)+","+DoubleToString(BarOpen,8)+","+DoubleToString(BarLength,8)+","+DoubleToString(MA5)+","+DoubleToString(TopBand,8)+","+DoubleToString(BaseBand,8)+","+DoubleToString(LowerBand,8)+","+Result);
         int test = StringReplace(toprint,",",",");
         if(!(test<8)){
            FileWrite(file_handle3,toprint);
         }
         }
         FileClose(file_handle4);
         FileClose(file_handle3);
         FileClose(file_handle2);
         FileClose(file_handle);
      }
      }
}