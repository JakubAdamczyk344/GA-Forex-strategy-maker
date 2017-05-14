//+------------------------------------------------------------------+
//|                                                    my_oop_ea.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
// Include  our class
#include <EAClass.mqh>
//--- input parameters
input int      StopLoss=30;      // Stop Loss
input int      TakeProfit=100;   // Take Profit
input int      ADX_Period=14;    // ADX Period
input int      MA_Period=10;     // Moving Average Period
input int      magicNumber=12345;   // EA Magic Number
input double   Adx_Min=22.0;     // Minimum ADX Value
input double   volume=0.2;          // volumes to Trade
input int      checkMargin=0;     // Check Margin before placing trade(0=No, 1=Yes)
input double   margin=15.0; // Percentage of Free Margin To use for Trading
//--- other parameters
int stp,tkp;   // To be used for Stop Loss & Take Profit values
//--- create an object of our class
EAClass Expert;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- run Initialize function
   Expert.doInit(ADX_Period,MA_Period);
//--- set all other necessary variables for our class object
   Expert.setPeriod(_Period);    // sets the chart period/timeframe
   Expert.setSymbol(_Symbol);    // sets the chart symbol/currency-pair
   Expert.setMagic(magicNumber);    // sets the Magic Number
   Expert.setadxmin(Adx_Min);    // sets the ADX miniumm value
   Expert.setVolume(volume);          // set the volumes value
   Expert.setCheckMargin(checkMargin); // set the margin check variable
   Expert.setMargin(margin); // set the percentage of Free Margin for trade
//--- let us handle brokers that offers 5 digit prices instead of 4
   stp = StopLoss;
   tkp = TakeProfit;
   if(_Digits==5)
     {
      stp = stp*10;
      tkp = tkp*10;
     }
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Run UnIntilialize function
   Expert.doUninit();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- do we have enough bars to work with
   int numberOfBars=Bars(_Symbol,_Period);
   if(numberOfBars<60) // if total bars is less than 60 bars
     {
      Alert("We have less than 60 bars, EA will now exit!!");
      return;
     }

//--- define some MQL5 Structures we will use for our trade
   MqlTick latestPrice;      // To be used for getting recent/latest price quotes
   MqlRates rates[];          // To be used to store the prices, volumes and spread of each bar
/*
     Let's make sure our arrays values for the Rates
     is store serially similar to the timeseries array
*/
//--- the rates arrays
   ArraySetAsSeries(rates,true);

//--- Get the last price quote using the MQL5 MqlTick Structure
   if(!SymbolInfoTick(_Symbol,latestPrice))
     {
      Alert("Error getting the latest price quote - error:",GetLastError(),"!!");
      return;
     }

//--- get the details of the latest 3 bars
   if(CopyRates(_Symbol,_Period,0,3,rates)<0)
     {
      Alert("Error copying rates/history data - error:",GetLastError(),"!!");
      return;
     }

//--- EA should only check for new trade if we have a new bar
//--- lets declare a static datetime variable
   static datetime prevTime;
//--- lets declare a datetmie variable to hold the start time for the current bar (Bar 0)
   datetime barTime[1];

//--- copy the start time of the new bar to the variable
   barTime[0]=rates[0].time;
//--- we don't have a new bar when both times are the same
   if(prevTime==barTime[0])
     {
      return;
     }
//--- copy time to static value, save
   prevTime=barTime[0];

//--- we have no errors, so continue
//--- do we have positions opened already?
   bool buyOpened=false,sellOpened=false; // variables to hold the result of the opened position

   if(PositionSelect(_Symbol)==true) // we have an opened position
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         buyOpened=true;  //It is a Buy
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         sellOpened=true; // It is a Sell
        }
     }
//--- copy the bar close price for the previous bar prior to the current bar, that is Bar 1
   Expert.setPrice(rates[1].close);  // bar 1 close price
//--- check for Buy position
   if(Expert.checkBuy()==true)
     {
      //--- do we already have an opened buy position
      if(buyOpened)
        {
         Alert("We already have a Buy Position!!!");
         return;    // Don't open a new Buy Position
        }
      double askPrice = NormalizeDouble(latestPrice.ask,_Digits);              // current Ask price
      double stl    = NormalizeDouble(latestPrice.ask - stp*_Point,_Digits); // Stop Loss
      double tkp    = NormalizeDouble(latestPrice.ask + tkp*_Point,_Digits); // Take profit
      int    mdev   = 100;                                                    // Maximum deviation
                                                                              // place order
      Expert.openBuy(ORDER_TYPE_BUY,askPrice,stl,tkp,mdev);
     }
//--- check for any Sell position
   if(Expert.checkSell()==true)
     {
      //--- do we already have an opened Sell position
      if(sellOpened)
        {
         Alert("We already have a Sell position!!!");
         return;    // Don't open a new Sell Position
        }
      double bidPrice=NormalizeDouble(latestPrice.bid,_Digits);                 // Current Bid price
      double bstl    = NormalizeDouble(latestPrice.bid + stp*_Point,_Digits); // Stop Loss
      double btkp    = NormalizeDouble(latestPrice.bid - tkp*_Point,_Digits); // Take Profit
      int    bdev=100;                                                         // Maximum deviation
                                                                               // place order
      Expert.openSell(ORDER_TYPE_SELL,bidPrice,bstl,btkp,bdev);
     }

   return;
  }
//+------------------------------------------------------------------+
