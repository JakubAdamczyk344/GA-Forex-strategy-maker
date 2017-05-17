//+------------------------------------------------------------------+
//|                                              my_expert_class.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| Deklaracja klasy                                                 |
//+------------------------------------------------------------------+
class EAClass
  {
private:
   int               magicNumber;   //Expert Magic Number
   int               checkMargin; //Czy sprawdzać wolne środki przed zawarciem transakcji? (1 albo 0)
   double            volume;       //wolumen pozycji
   double            marginPercentage;   //Procent wolnych środków jakiego nie może przekroczyć otwierana pozycja
   double            ADX_min;    //ADX Minimum value
   int               ADX_handle; //ADX Handle
   int               MA_handle;  //Moving Average Handle
   double            plus_DI[];  //array to hold ADX +DI values for each bars
   double            minus_DI[]; //array to hold ADX -DI values for each bars
   double            MA_val[];   //array to hold Moving Average values for each bars
   double            ADX_val[];  //array to hold ADX values for each bars
   double            price; //Zmienna przechowująca ostatni kurs pary walutowej
   MqlTradeRequest   tradeRequest;   //Struktura MQL5 trade request do otwierania pozycji
   MqlTradeResult    tradeResult;    //Struktura MQL5 trade result do pobierania wyniku pozycji
   string            symbol;     //Para walutowa na której gram
   ENUM_TIMEFRAMES   period;     //Okres próbkowania kursu walutowego
   string            errorMsq;   //Zmienna do przechowywania treści błędu
   int               errorCode;    //Zmienna do przechowywania kodu błędu
public:
   void              EAClass();                                  //Konstruktor obiektu klasy EAClass
   void              setSymbol(string syb){symbol = syb;}         //Metoda do ustawienia pary walutowej
   void              setPeriod(ENUM_TIMEFRAMES prd){period = prd;}//Metoda do ustawienia okresu próbkowania
   void              setPrice(double prc){price=prc;}   //Metoda do ustawieniego kursu
   void              setCheckMargin(int mag){checkMargin=mag;}          //Metoda do ustawienia czy sprawdzać margines
   void              setVolume(double vol){volume=vol;}               //Metoda do ustawienia wolumenu
   void              setMargin(double margin){marginPercentage=margin/100;}  //Metoda do ustawiania jaki procent marginesu jest niezbędny do otworzenia transakcji
   void              setMagic(int magic){magicNumber=magic;}         //Metoda do ustawienia Expert Magic Number
   void              setadxmin(double adx){ADX_min=adx;}          //function to set ADX Minimum values
   void              doInit(int adx_period,int ma_period);        //function to be used at our EA intialization
   void              doUninit();                                  //Metoda obsługująca zdarzenie Unitit
   bool              checkBuy();                                  //Metoda sprawdzająca czy można dokonać kupna
   bool              checkSell();                                 //Metoda sprawdzająca czy można dokonać sprzedaży
   void              openBuy(ENUM_ORDER_TYPE otype,double askprice,double SL,
                             double TP,int dev,string comment=""); //Metoda do otwierania pozycji kupna
   void              openSell(ENUM_ORDER_TYPE otype,double bidprice,double SL,
                              double TP,int dev,string comment=""); //Metoda do otwierania pozycji sprzedaży

protected:
   void              showError(string msg, int ercode);           //Metoda do wyświetlania errorów
   void              getBuffers();                                //Metoda do pobierania buforów wskaźników
   bool              MarginOK();                                  //Metoda sprawdziająca czy na koncie znajduje się odpowiednia liczna środków (zgodnie z wymaganym marginesiem)
  };

void EAClass::EAClass()
  {
//Inicjalizacja potrzebnych wartości
//Kasowanie zawartości tablic
   ZeroMemory(tradeRequest);
   ZeroMemory(tradeResult);
   ZeroMemory(ADX_val);
   ZeroMemory(MA_val);
   ZeroMemory(plus_DI);
   ZeroMemory(minus_DI);
   errorMsq="";
   errorCode=0;
  }

void EAClass::showError(string msg,int ercode)
  }
   //Wyświetlenie errora
   Alert(msg,"-error:",ercode,"!!");
  }

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

bool EAClass::MarginOK()
  {
   double oneLotPrice;                                                        //Cena jednego lota z uwzg dźwigni
   double accFreeMarg     = AccountInfoDouble(ACCOUNT_FREEMARGIN);                //Wolne środki
   long   leverage       = AccountInfoInteger(ACCOUNT_LEVERAGE);                 //Dźwignia dla tego konta
   double contractSize = SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);  //Wielkość lota
   string baseCurrency = SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE);        //Waluta bazowa

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

void EAClass::doInit(int adx_period,int ma_period)
  {
//--- get handle for ADX indicator
   ADX_handle=iADX(symbol,period,adx_period);
//--- get the handle for Moving Average indicator
   MA_handle=iMA(symbol,period,ma_period,0,MODE_EMA,PRICE_CLOSE);
   //Jeśli wystąpi błąd przy tworzeniu uchwytów do wskaźników
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

void EAClass::doUninit()
  {
   IndicatorRelease(ADX_handle);
   IndicatorRelease(MA_handle);
  }

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

void EAClass::openBuy(ENUM_ORDER_TYPE otype,double askprice,double SL,double TP,int dev,string comment="")
  {
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

         OrderSend(tradeRequest,tradeResult);
         //Jeśli wykonano zlecenie
         if(tradeResult.retcode==10009 || tradeResult.retcode==10008)
           {
            Alert("A Buy order has been successfully placed with Ticket#:",tradeResult.order,"!!");
           }
         //Jeśli wystąpił błąd
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
      
      OrderSend(tradeRequest,tradeResult);
      //Jeśli wykonano zlecenie
      if(tradeResult.retcode==10009 || tradeResult.retcode==10008)
        {
         Alert("A Buy order has been successfully placed with Ticket#:",tradeResult.order,"!!");
        }
      //Jeśli wystąpił błąd
      else
        {
         errorMsq= "The Buy order request could not be completed";
         errorCode =GetLastError();
         showError(errorMsq,errorCode);
        }
     }
  }

void EAClass::openSell(ENUM_ORDER_TYPE otype,double bidprice,double SL,double TP,int dev,string comment="")
  {
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

         OrderSend(tradeRequest,tradeResult);
         //Jeśli wykonano zlecenie
         if(tradeResult.retcode==10009 || tradeResult.retcode==10008) //Request successfully completed 
           {
            Alert("A Sell order has been successfully placed with Ticket#:",tradeResult.order,"!!");
           }
         //Jeśli wystąpił błąd
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

      OrderSend(tradeRequest,tradeResult);
      //Jeśli wykonano zlecenie
      if(tradeResult.retcode==10009 || tradeResult.retcode==10008)
        {
         Alert("A Sell order has been successfully placed with Ticket#:",tradeResult.order,"!!");
        }
      //Jeśli wystąpił błąd
      else
        {
         errorMsq= "The Sell order request could not be completed";
         errorCode =GetLastError();
         showError(errorMsq,errorCode);
        }
     }
  }
//+----------------------------------------------------------------+