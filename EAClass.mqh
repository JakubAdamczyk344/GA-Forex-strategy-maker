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
   double            price; //Zmienna przechowująca ostatni kurs pary walutowej
   MqlTradeRequest   tradeRequest;   //Struktura MQL5 trade request do otwierania pozycji
   MqlTradeResult    tradeResult;    //Struktura MQL5 trade result do pobierania wyniku pozycji
   string            errorMsq;   //Zmienna do przechowywania treści błędu
   int               errorCode;    //Zmienna do przechowywania kodu błędu
   int               howManyResults; //Określa ile rezulatatów ostatnich transakcji jest przechowywanych
   double            tradeResults[]; //Przechowuje wyniki ostatnich transakcji
public:
   string            symbol;     //Para walutowa na której gram
   ENUM_TIMEFRAMES   period;     //Okres próbkowania kursu walutowego
   void              EAClass(int howManyResults);                                  //Konstruktor obiektu klasy EAClass
   void              setSymbol(string syb){symbol = syb;}         //Metoda do ustawienia pary walutowej
   void              setPeriod(ENUM_TIMEFRAMES prd){period = prd;}//Metoda do ustawienia okresu próbkowania
   void              setPrice(double prc){price=prc;}   //Metoda do ustawieniego kursu
   void              setCheckMargin(int mag){checkMargin=mag;}          //Metoda do ustawienia czy sprawdzać margines
   void              setVolume(double vol){volume=vol;}               //Metoda do ustawienia wolumenu
   void              setMargin(double margin){marginPercentage=margin/100;}  //Metoda do ustawiania jaki procent marginesu jest niezbędny do otworzenia transakcji
   void              setMagic(int magic){magicNumber=magic;}         //Metoda do ustawienia Expert Magic Number
   void              openBuy(ENUM_ORDER_TYPE otype,double askprice,double SL,
                             double TP,int dev,string comment=""); //Metoda do otwierania pozycji kupna
   void              openSell(ENUM_ORDER_TYPE otype,double bidprice,double SL,
                              double TP,int dev,string comment=""); //Metoda do otwierania pozycji sprzedaży
   void              addTradeResult(double tradeResult); //Metoda wstawiająca do tablicy tradeResults rezultat ostatniej transakcji
   double            result; //Przechowuje wynik pojedyńczej transakcji
   double            previousBalance; //poprzedni stan konta
   double            currentBalance; //obecny stan konta
   bool              checkTradeResults(); //Metoda do sprawdzania rezultatu ostatnich transakcji
   int               resultsCounter; //zlicza ile rezultatów dodano do tablicy

protected:
   void              showError(string msg, int ercode);           //Metoda do wyświetlania errorów
   bool              MarginOK();                                  //Metoda sprawdziająca czy na koncie znajduje się odpowiednia liczna środków (zgodnie z wymaganym marginesiem)
  };

void EAClass::EAClass(int howMany)
  {
   //Inicjalizacja potrzebnych wartości
   //Kasowanie zawartości tablic
   ZeroMemory(tradeRequest);
   ZeroMemory(tradeResult);
   errorMsq="";
   errorCode=0;
   howManyResults = howMany;
   //Tworzenie tablicy do przechowywania rezultatów transakcji
   ArrayResize(tradeResults,howManyResults);
   resultsCounter = 0;
  }

void EAClass::showError(string msg,int ercode)
  {
   //Wyświetlenie errora
   Alert(msg,"-error:",ercode,"!!");
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

void EAClass::addTradeResult(double res)
{  
   //Zwiększamy licznik dodanych do tablicy rezultatów
   if (resultsCounter < howManyResults) {resultsCounter++;}
   for (int i = howManyResults - 2; i >= 0; i--)
   {
      tradeResults[i+1] = tradeResults[i];
   }
   tradeResults[0] = res;
}

bool EAClass::checkTradeResults()
{
   //Sprawdzamy rezultat ostatnich pozycji tylko jeśli tablica została zapełniona
   if (resultsCounter == howManyResults)
   {
      double res = 0;
      for (int i = 0; i < howManyResults; i++)
      {
         res = res + tradeResults[i];
      }
      if (res > 0) {return false;}
      else {return true;}
   }
   else {return false;}
}