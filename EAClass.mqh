//+------------------------------------------------------------------+
//|                                              my_expert_class.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
input string WasOpenFileName="wasPositionOpen.csv";
input string WasOpenDirectoryName="ResultsOpt//WasPosOpen";
input string ResultCounterFileName="ResultCounter.bin";
input string ResultCounterDirectoryName="ResultsOpt//ResultCounter";
input string TradeResultsFileName="TradeResults.bin";
input string TradeResultsDirectoryName="ResultsOpt//TradeResults";
input string PreviousBalanceFileName="PreviousBalance.bin";
input string PreviousBalanceDirectoryName="ResultsOpt//PreviousBalance";

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
   string            tradeResultsFilePath; //Ścieżka do pliku z tablicą z rezultatami transakcji
   string            wasOpenFilePath; //Ścieżka do pliku ze zmienną mówiącą czy była już otwarta pozycja
   string            resultCounterFilePath; //Ścieżka do pliku z licznikiem ostatnich transakcji
   string            previousBalanceFilePath; //Ścieżka do pliku z bilansem poprzedniej transakcji
   
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
   void              printTradeResults(); //Metoda drukująca do tablice tradeResults do pliku
   void              getTradeResult(); //Metoda wczytująca tablicę tradeResults z pliku
   void              printWasPositionOpen(); //Metoda drukująca wasPositionOpen do pliku
   void              getWasPositionOpen(); //Metoda wczytująca wasPositionOpen z pliku
   void              printResultsCounter(); //Metoda zapisująca resultsCounter do pliku
   void              getResultsCounter(); //Metoda wczytująca resultsCounter z pliku
   void              printPreviousBalance(); //Metoda zapisująca do pliku bilans poprzedniej transakcji
   void              getPreviousBalance(); //Metoda wczytująca previousBalance z pliku
   double            result; //Przechowuje wynik pojedyńczej transakcji
   double            previousBalance; //poprzedni stan konta
   double            currentBalance; //obecny stan konta
   bool              checkTradeResults(); //Metoda do sprawdzania rezultatu ostatnich transakcji
   int               resultsCounter; //zlicza ile rezultatów dodano do tablicy
   bool              wasPositionOpen; //Przechowuje informacje, czy była już otwarta pozycja

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
   
   tradeResultsFilePath=TradeResultsDirectoryName+"//"+TradeResultsFileName;
   wasOpenFilePath=WasOpenDirectoryName+"//"+WasOpenFileName;
   resultCounterFilePath=ResultCounterDirectoryName+"//"+ResultCounterFileName;
   previousBalanceFilePath=PreviousBalanceDirectoryName+"//"+PreviousBalanceFileName;
   //Tworzenie tablicy do przechowywania rezultatów transakcji
   ArrayResize(tradeResults,howManyResults);
   if(FileIsExist(tradeResultsFilePath)) {getTradeResult();}
   if(FileIsExist(resultCounterFilePath)) {getResultsCounter();} else {resultsCounter = 0;}
   if(FileIsExist(wasOpenFilePath)) {getWasPositionOpen();} else {wasPositionOpen = false;}
   if(FileIsExist(previousBalanceFilePath)) {getPreviousBalance();} else {previousBalance = 0;}
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
   if (resultsCounter <= howManyResults) {resultsCounter++; printResultsCounter();}
   for (int i = howManyResults - 2; i >= 0; i--)
   {
      tradeResults[i+1] = tradeResults[i];
   }
   tradeResults[0] = res;
   printTradeResults();
}

bool EAClass::checkTradeResults()
{
   //Sprawdzamy rezultat ostatnich pozycji tylko jeśli tablica została zapełniona
   //Dodaję 1 do howManyResults bo w EA inkrementuję resultsCounter przed sprawdzeniem czy należy optymalizować
   if (resultsCounter == howManyResults + 1)
   {
      double res = 0;
      for (int i = 0; i < howManyResults; i++)
      {
         res = res + tradeResults[i];
      }
      if (res > 0) {return false;}
      else
      {
         for (int i = 0; i < howManyResults; i++)
         {
            printf(tradeResults[i]);
         }
         return true;
      }
   }
   else {return false;}
}

void EAClass::printTradeResults()
{
   FolderClean(TradeResultsDirectoryName);
	int tradeResultsFileHandle=FileOpen(tradeResultsFilePath,FILE_READ|FILE_WRITE|FILE_BIN);
	FileWriteArray(tradeResultsFileHandle,tradeResults);
	FileClose(tradeResultsFileHandle);
}
void EAClass::getTradeResult()
{
	int tradeResultsFileHandle=FileOpen(tradeResultsFilePath,FILE_READ|FILE_WRITE|FILE_BIN);
	FileReadArray(tradeResultsFileHandle,tradeResults);
	FileClose(tradeResultsFileHandle);
}
void EAClass::printWasPositionOpen()
{
   FolderClean(WasOpenDirectoryName);
	int wasOpenFileHandle=FileOpen(wasOpenFilePath,FILE_READ|FILE_WRITE|FILE_CSV);
	FileWrite(wasOpenFileHandle,wasPositionOpen);
	FileClose(wasOpenFileHandle);
}
void EAClass::getWasPositionOpen()
{
	int wasOpenFileHandle=FileOpen(wasOpenFilePath,FILE_READ|FILE_WRITE|FILE_CSV);
	wasPositionOpen = FileReadBool(wasOpenFileHandle);
	FileClose(wasOpenFileHandle);
}
void EAClass::printResultsCounter()
{
   FolderClean(ResultCounterDirectoryName);
	int resultCounterFileHandle=FileOpen(resultCounterFilePath,FILE_READ|FILE_WRITE|FILE_BIN);
	FileWriteInteger(resultCounterFileHandle,resultsCounter);
	FileClose(resultCounterFileHandle);
}
void EAClass::getResultsCounter()
{
	int resultCounterFileHandle=FileOpen(resultCounterFilePath,FILE_READ|FILE_WRITE|FILE_BIN);
	resultsCounter = FileReadInteger(resultCounterFileHandle);
	FileClose(resultCounterFileHandle);
}

void EAClass::printPreviousBalance()
{
   FolderClean(PreviousBalanceDirectoryName);
	int previousBalanceFileHandle=FileOpen(previousBalanceFilePath,FILE_READ|FILE_WRITE|FILE_BIN);
	FileWriteDouble(previousBalanceFileHandle,previousBalance);
	FileClose(previousBalanceFileHandle);
}
void EAClass::getPreviousBalance()
{
	int previousBalanceFileHandle=FileOpen(previousBalanceFilePath,FILE_READ|FILE_WRITE|FILE_BIN);
	previousBalance = FileReadDouble(previousBalanceFileHandle);
	FileClose(previousBalanceFileHandle);
}