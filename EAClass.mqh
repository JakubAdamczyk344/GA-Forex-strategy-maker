//+------------------------------------------------------------------+
//|                                              my_expert_class.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| CLASS DECLARATION                                                |
//+------------------------------------------------------------------+
class EAClass
  {
   //--- private members
private:
   int               magicNumber;   //Expert Magic Number
   int               checkMargin; //Margin Check before placing trade? (1 or 0)
   double            volume;       //volume or volume to Trade
   double            marginPercentage;   //Percentage of Account Free Margin to trade
   double            ADX_min;    //ADX Minimum value
   int               ADX_handle; //ADX Handle
   int               MA_handle;  //Moving Average Handle
   double            plus_DI[];  //array to hold ADX +DI values for each bars
   double            minus_DI[]; //array to hold ADX -DI values for each bars
   double            MA_val[];   //array to hold Moving Average values for each bars
   double            ADX_val[];  //array to hold ADX values for each bars
   double            price; //variable to hold the previous bar closed price 
   MqlTradeRequest   tradeRequest;   //MQL5 trade request structure to be used for sending our trade requests
   MqlTradeResult    tradeResult;    //MQL5 trade result structure to be used to get our trade results
   string            symbol;     //variable to hold the current symbol name
   ENUM_TIMEFRAMES   period;     //variable to hold the current timeframe value
   string            errorMsq;   //variable to hold our error messages
   int               errorCode;    //variable to hold our error codes
   //--- Public member/functions
public:
   void              EAClass();                                  //Class Constructor
   void              setSymbol(string syb){symbol = syb;}         //function to set current symbol
   void              setPeriod(ENUM_TIMEFRAMES prd){period = prd;}//function to set current symbol timeframe/period
   void              setPrice(double prc){price=prc;}   //function to set prev bar closed price
   void              setCheckMargin(int mag){checkMargin=mag;}          //function to set Margin Check value
   void              setVolume(double vol){volume=vol;}               //function to set The Lot size to trade
   void              setMargin(double margin){marginPercentage=margin/100;}  //function to set Percentage of Free margin to use for trading
   void              setMagic(int magic){magicNumber=magic;}         //function to set Expert Magic number
   void              setadxmin(double adx){ADX_min=adx;}          //function to set ADX Minimum values
   void              doInit(int adx_period,int ma_period);        //function to be used at our EA intialization
   void              doUninit();                                  //function to be used at EA de-initialization
   bool              checkBuy();                                  //function to check for Buy conditions
   bool              checkSell();                                 //function to check for Sell conditions
   void              openBuy(ENUM_ORDER_TYPE otype,double askprice,double SL,
                             double TP,int dev,string comment=""); //function to open Buy positions
   void              openSell(ENUM_ORDER_TYPE otype,double bidprice,double SL,
                              double TP,int dev,string comment=""); //function to open Sell positions

   //--- Protected members
protected:
   void              showError(string msg, int ercode);           //function for use to display error messages
   void              getBuffers();                                //function for getting Indicator buffers
   bool              MarginOK();                                  //function to check if margin required for volume is OK
  };   // end of class declaration
//+------------------------------------------------------------------+
//| Definition of our Class/member functions                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  This CLASS CONSTRUCTOR                                          |
//|  *Does not have any input parameters                             |
//|  *Initilizes all the necessary variables                         |                 
//+------------------------------------------------------------------+
void EAClass::EAClass()
  {
//---initialize all necessary variables
   ZeroMemory(tradeRequest);
   ZeroMemory(tradeResult);
   ZeroMemory(ADX_val);
   ZeroMemory(MA_val);
   ZeroMemory(plus_DI);
   ZeroMemory(minus_DI);
   errorMsq="";
   errorCode=0;
  }
  
//+------------------------------------------------------------------+
//|  SHOWERROR FUNCTION                                              |
//|  *Input Parameters - Error Message, Error Code                   |
//+------------------------------------------------------------------+
void EAClass::showError(string msg,int ercode)
  {
   Alert(msg,"-error:",ercode,"!!"); // display error
  }
  
//+------------------------------------------------------------------+
//|  GETBUFFERS FUNCTION                                             |                   
//|  *No input parameters                                            |
//|  *Uses the class data members to get indicator's buffers         |
//+------------------------------------------------------------------+
void EAClass::getBuffers()
  {
   if(CopyBuffer(ADX_handle,0,0,3,ADX_val)<0 || CopyBuffer(ADX_handle,1,0,3,plus_DI)<0
      || CopyBuffer(ADX_handle,2,0,3,minus_DI)<0 || CopyBuffer(MA_handle,0,0,3,MA_val)<0)
     {
      errorMsq="Error copying indicator Buffers";
      errorCode = GetLastError();
      showError(errorMsq,errorCode);
     }
  }
  
//+------------------------------------------------------------------+
//| MARGINOK FUNCTION                                                |
//| *No input parameters                                             |
//| *Uses the Class data members to check margin required to place   |
//| a trade with the lot size is ok                                  |
//| *Returns TRUE on success and FALSE on failure                    |
//+------------------------------------------------------------------+
bool EAClass::MarginOK()
  {
   double oneLotPrice;                                                        //Margin required for one lot
   double accFreeMarg     = AccountInfoDouble(ACCOUNT_FREEMARGIN);                //Account free margin
   long   leverage       = AccountInfoInteger(ACCOUNT_LEVERAGE);                 //Leverage for this account
   double contractSize = SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);  //Total units for one lot
   string baseCurrency = SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE);        //Base currency for currency pair
                                                                                //
   if(baseCurrency=="USD")
     {
      oneLotPrice=contractSize/leverage;
     }
   else
     {
      double bprice= SymbolInfoDouble(symbol,SYMBOL_BID);
      oneLotPrice=bprice*contractSize/leverage;
     }
// Check if margin required is okay based on setting
   if(MathFloor(volume*oneLotPrice)>MathFloor(accFreeMarg*marginPercentage))
     {
      return(false);
     }
   else
     {
      return(true);
     }
  }
  
  
//+-----------------------------------------------------------------------+
//| OUR PUBLIC FUNCTIONS                                                  |
//+-----------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| DOINIT FUNCTION                                                  |
//| *Takes the ADX indicator's Period and Moving Average indicator's |
//| period as input parameters                                       |
//| *To be used in the OnInit() function of our EA                   |                                            
//+------------------------------------------------------------------+
void EAClass::doInit(int adx_period,int ma_period)
  {
//--- get handle for ADX indicator
   ADX_handle=iADX(symbol,period,adx_period);
//--- get the handle for Moving Average indicator
   MA_handle=iMA(symbol,period,ma_period,0,MODE_EMA,PRICE_CLOSE);
//--- what if handle returns Invalid Handle
   if(ADX_handle<0 || MA_handle<0)
     {
      errorMsq="Error Creating Handles for indicators";
      errorCode=GetLastError();
      showError(errorMsq,errorCode);
     }
//--- set Arrays as series
//--- the ADX values arrays
   ArraySetAsSeries(ADX_val,true);
//--- the +DI value arrays
   ArraySetAsSeries(plus_DI,true);
//--- the -DI value arrays
   ArraySetAsSeries(minus_DI,true);
//--- the MA values arrays
   ArraySetAsSeries(MA_val,true);
  }
  
//+------------------------------------------------------------------+
//|  DOUNINIT FUNCTION                                               |
//|  *No input parameters                                            |
//|  *Used to release ADX and MA indicators handles                  |
//+------------------------------------------------------------------+
void EAClass::doUninit()
  {
//--- release our indicator handles
   IndicatorRelease(ADX_handle);
   IndicatorRelease(MA_handle);
  }


//+------------------------------------------------------------------+
//| CHECKBUY FUNCTION                                                |
//| *No input parameters                                             |
//| *Uses the class data members to check for Buy setup              |
//| based on the defined trade strategy                              |
//| *Returns TRUE if Buy conditions are met or FALSE if not met      |
//+------------------------------------------------------------------+
bool EAClass::checkBuy()
  {
/*
    Check for a Long/Buy Setup : MA increasing upwards, 
    previous price close above MA, ADX > ADX min, +DI > -DI
*/
   getBuffers();
//--- declare bool type variables to hold our Buy Conditions
   bool Buy_Condition_1=(MA_val[0]>MA_val[1]) && (MA_val[1]>MA_val[2]); // MA Increasing upwards
   bool Buy_Condition_2=(price>MA_val[1]);                         // previous price closed above MA
   bool Buy_Condition_3=(ADX_val[0]>ADX_min);                           // Current ADX value greater than minimum ADX value
   bool Buy_Condition_4=(plus_DI[0]>minus_DI[0]);                       // +DI greater than -DI
//--- Putting all together   
   if(Buy_Condition_1 && Buy_Condition_2 && Buy_Condition_3 && Buy_Condition_4)
     {
      return(true);
     }
   else
     {
      return(false);
     }
  }
  
//+------------------------------------------------------------------+
//| CHECKSELL FUNCTION                                               |
//| *No input parameters                                             |
//| *Uses the class data members to check for Sell setup             |
//|  based on the defined trade strategy                             |
//| *Returns TRUE if Sell conditions are met or FALSE if not met     |
//+------------------------------------------------------------------+
bool EAClass::checkSell()
  {
/*
    Check for a Short/Sell Setup : MA decreasing downwards, 
    previous price close below MA, ADX > ADX min, -DI > +DI
*/
   getBuffers();
//--- declare bool type variables to hold our Sell Conditions
   bool Sell_Condition_1=(MA_val[0]<MA_val[1]) && (MA_val[1]<MA_val[2]);  // MA decreasing downwards
   bool Sell_Condition_2=(price <MA_val[1]);                         // Previous price closed below MA
   bool Sell_Condition_3=(ADX_val[0]>ADX_min);                            // Current ADX value greater than minimum ADX
   bool Sell_Condition_4=(plus_DI[0]<minus_DI[0]);                        // -DI greater than +DI

//--- putting all together
   if(Sell_Condition_1 && Sell_Condition_2 && Sell_Condition_3 && Sell_Condition_4)
     {
      return(true);
     }
   else
     {
      return(false);
     }
  }
  
//+------------------------------------------------------------------+
//| OPENBUY FUNCTION                                                 |
//| *Has Input parameters - order type, Current ASK price,           |
//|  Stop Loss, Take Profit, deviation, comment                      |
//| *Checks account free margin before pacing trade if trader chooses|
//| *Alerts of a success if position is opened or shows error        |
//+------------------------------------------------------------------+
void EAClass::openBuy(ENUM_ORDER_TYPE otype,double askprice,double SL,double TP,int dev,string comment="")
  {
//--- do check Margin if enabled
   if(checkMargin==1)
     {
      if(MarginOK()==false)
        {
         errorMsq= "You do not have enough money to open this Position!!!";
         errorCode =GetLastError();
         showError(errorMsq,errorCode);
        }
      else
        {
         tradeRequest.action=TRADE_ACTION_DEAL;
         tradeRequest.type=otype;
         tradeRequest.volume=volume;
         tradeRequest.price=askprice;
         tradeRequest.sl=SL;
         tradeRequest.tp=TP;
         tradeRequest.deviation=dev;
         tradeRequest.magic=magicNumber;
         tradeRequest.symbol=symbol;
         tradeRequest.type_filling=ORDER_FILLING_FOK;
         //--- send
         OrderSend(tradeRequest,tradeResult);
         //--- check result
         if(tradeResult.retcode==10009 || tradeResult.retcode==10008) //Request successfully completed 
           {
            Alert("A Buy order has been successfully placed with Ticket#:",tradeResult.order,"!!");
           }
         else
           {
            errorMsq= "The Buy order request could not be completed";
            errorCode =GetLastError();
            showError(errorMsq,errorCode);
           }
        }
     }
   else
     {
      tradeRequest.action=TRADE_ACTION_DEAL;
      tradeRequest.type=otype;
      tradeRequest.volume=volume;
      tradeRequest.price=askprice;
      tradeRequest.sl=SL;
      tradeRequest.tp=TP;
      tradeRequest.deviation=dev;
      tradeRequest.magic=magicNumber;
      tradeRequest.symbol=symbol;
      tradeRequest.type_filling=ORDER_FILLING_FOK;
      //--- send
      OrderSend(tradeRequest,tradeResult);
      //--- check result
      if(tradeResult.retcode==10009 || tradeResult.retcode==10008) //Request successfully completed 
        {
         Alert("A Buy order has been successfully placed with Ticket#:",tradeResult.order,"!!");
        }
      else
        {
         errorMsq= "The Buy order request could not be completed";
         errorCode =GetLastError();
         showError(errorMsq,errorCode);
        }
     }
  }

//+------------------------------------------------------------------+
//| OPENSELL FUNCTION                                                |
//| *Has Input parameters - order type, Current BID price, Stop Loss,|
//|  Take Profit, deviation, comment                                 |
//| *Checks account free margin before pacing trade if trader chooses|
//| *Alerts of a success if position is opened or shows error        |
//+------------------------------------------------------------------+
void EAClass::openSell(ENUM_ORDER_TYPE otype,double bidprice,double SL,double TP,int dev,string comment="")
  {
//--- do check Margin if enabled
   if(checkMargin==1)
     {
      if(MarginOK()==false)
        {
         errorMsq= "You do not have enough money to open this Position!!!";
         errorCode =GetLastError();
         showError(errorMsq,errorCode);
        }
      else
        {
         tradeRequest.action=TRADE_ACTION_DEAL;
         tradeRequest.type=otype;
         tradeRequest.volume=volume;
         tradeRequest.price=bidprice;
         tradeRequest.sl=SL;
         tradeRequest.tp=TP;
         tradeRequest.deviation=dev;
         tradeRequest.magic=magicNumber;
         tradeRequest.symbol=symbol;
         tradeRequest.type_filling=ORDER_FILLING_FOK;
         //--- send
         OrderSend(tradeRequest,tradeResult);
         //--- check result
         if(tradeResult.retcode==10009 || tradeResult.retcode==10008) //Request successfully completed 
           {
            Alert("A Sell order has been successfully placed with Ticket#:",tradeResult.order,"!!");
           }
         else
           {
            errorMsq= "The Sell order request could not be completed";
            errorCode =GetLastError();
            showError(errorMsq,errorCode);
           }
        }
     }
   else
     {
      tradeRequest.action=TRADE_ACTION_DEAL;
      tradeRequest.type=otype;
      tradeRequest.volume=volume;
      tradeRequest.price=bidprice;
      tradeRequest.sl=SL;
      tradeRequest.tp=TP;
      tradeRequest.deviation=dev;
      tradeRequest.magic=magicNumber;
      tradeRequest.symbol=symbol;
      tradeRequest.type_filling=ORDER_FILLING_FOK;
      //--- send
      OrderSend(tradeRequest,tradeResult);
      //--- check result
      if(tradeResult.retcode==10009 || tradeResult.retcode==10008) //Request successfully completed 
        {
         Alert("A Sell order has been successfully placed with Ticket#:",tradeResult.order,"!!");
        }
      else
        {
         errorMsq= "The Sell order request could not be completed";
         errorCode =GetLastError();
         showError(errorMsq,errorCode);
        }
     }
  }
//+----------------------------------------------------------------+