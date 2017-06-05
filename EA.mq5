//+------------------------------------------------------------------+
//|                                                    my_oop_ea.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//Dołączam AG i Experta
#include <EAClass.mqh>
#include <GABase.mqh>
input string TreeFileName="tree.bin";
input string MaFileName="ma.bin";
input string AdxFileName="adx.bin";
input string RsiFileName="rsi.bin";
input string MacdFileName="macd.bin";
input string InpDirectoryName="Dane";
//Parametry wejściowe dla Expert Advisora
input int      StopLoss=30;      // Stop Loss
input int      TakeProfit=100;   // Take Profit
input int      magicNumber=12345;   // EA Magic Number
input double   volume=0.2;          //Wolumen handlu
input int      checkMargin=0;     //Czy sprawdzać margines (0=No, 1=Yes)
input double   margin=15.0; //Procent wolnych środków

int stp,tkp;   //Zmienne pomocnicze do stop loss i take profit

   //Utworzenie Expert Advisora
   EAClass Expert;
   //Tworzę obiekt klasy GABase, do którego wpiszę najlepszego osobnika
   GABase Best;
int OnInit()
  {
   //Wypełnienie osobnika, według którego będą testy przeprowadzane
   //Czytanie tablicy tree
   string treePath=InpDirectoryName+"//"+TreeFileName;
   int treeHandle=FileOpen(treePath,FILE_READ|FILE_BIN);
   if(treeHandle!=INVALID_HANDLE)
     {
      FileReadArray(treeHandle,Best.population[0].tree);
      int size=ArraySize(Best.population[0].tree);
      //Drukuj tablicę
      for(int i=0;i<size;i++)
         Print("Tree = ",Best.population[0].tree[i]);
      FileClose(treeHandle);
     }
   else
      Print("File open failed, error ",GetLastError());
   //Czytanie tablicy MAarray
   string maPath=InpDirectoryName+"//"+MaFileName;
   int maHandle=FileOpen(maPath,FILE_READ|FILE_BIN);
   if(maHandle!=INVALID_HANDLE)
     {
      FileReadArray(maHandle,Best.population[0].MAarray);
      int size=ArraySize(Best.population[0].MAarray);
      //Drukuj tablicę
      for(int i=0;i<size;i++)
         Print("MA = ",Best.population[0].MAarray[i]);
      FileClose(maHandle);
     }
   else
      Print("File open failed, error ",GetLastError());
   //Czytanie tablicy ADXarray
   string adxPath=InpDirectoryName+"//"+AdxFileName;
   int adxHandle=FileOpen(adxPath,FILE_READ|FILE_BIN);
   if(adxHandle!=INVALID_HANDLE)
     {
      FileReadArray(adxHandle,Best.population[0].ADXarray);
      int size=ArraySize(Best.population[0].ADXarray);
      //Drukuj tablicę
      for(int i=0;i<size;i++)
         Print("ADX = ",Best.population[0].ADXarray[i]);
      FileClose(adxHandle);
     }
   else
      Print("File open failed, error ",GetLastError());
   //Czytanie tablicy RSIarray
   string rsiPath=InpDirectoryName+"//"+RsiFileName;
   int rsiHandle=FileOpen(rsiPath,FILE_READ|FILE_BIN);
   if(rsiHandle!=INVALID_HANDLE)
     {
      FileReadArray(rsiHandle,Best.population[0].RSIarray);
      int size=ArraySize(Best.population[0].RSIarray);
      //Drukuj tablicę
      for(int i=0;i<size;i++)
         Print("RSI = ",Best.population[0].RSIarray[i]);
      FileClose(rsiHandle);
     }
   else
      Print("File open failed, error ",GetLastError());
   //Czytanie tablicy MACDarray
   string macdPath=InpDirectoryName+"//"+MacdFileName;
   int macdHandle=FileOpen(macdPath,FILE_READ|FILE_BIN);
   if(macdHandle!=INVALID_HANDLE)
     {
      FileReadArray(macdHandle,Best.population[0].MACDarray);
      int size=ArraySize(Best.population[0].MACDarray);
      //Drukuj tablicę
      for(int i=0;i<size;i++)
         Print("MACD = ",Best.population[0].MACDarray[i]);
      FileClose(macdHandle);
     }
   else
      Print("File open failed, error ",GetLastError());
   
   Expert.setPeriod(_Period); //Ustawienie aktualnego okresu próbkowania
   Expert.setSymbol("EURUSD"); //Ustawienie aktualnej pary walutowej
   Expert.setMagic(magicNumber);
   Expert.setVolume(volume);
   Expert.setCheckMargin(checkMargin);
   Expert.setMargin(margin);
   //Jeśli cena jest podawana z dokładnością do 5 miejsc po przecinku
   stp = StopLoss;
   tkp = TakeProfit;
   if(_Digits==5)
     {
      stp = stp*10;
      tkp = tkp*10;
     }

   return(0);
  }

void OnDeinit(const int reason)
  {
  }
  
void OnTick()
  {
   //Sprawdzenie czy jest dostatecznie dużo próbek do handlu
   int numberOfBars=Bars(Expert.symbol,Expert.period);
   if(numberOfBars<60) // if total bars is less than 60 bars
     {
      Alert("We have less than 60 bars, EA will now exit!!");
      return;
     }

   //Deklaracja struktur używanych do handlu
   MqlTick latestPrice;      //Informacje na temat cen
   MqlRates rates[];          //Przechowywanie cen, spreadu dla każdej próbki
   //Ustawiamy rates jako serię danych
   ArraySetAsSeries(rates,true);

   //Pobranie ostatniej ceny i zwrócenie błędu w razie niepowodzenia
   if(!SymbolInfoTick(Expert.symbol,latestPrice))
     {
      Alert("Error getting the latest price quote - error:",GetLastError(),"!!");
      return;
     }

   //Szczegółowe informacje na temat trzech ostatnich próbek
   if(CopyRates(Expert.symbol,Expert.period,0,3,rates)<0)
     {
      Alert("Error copying rates/history data - error:",GetLastError(),"!!");
      return;
     }
   
   //EA sprawdza czy można otworzyć pozycję, gdy jest nowa próbka
   static datetime prevTime;
   //Bęzdziemy zapisywać tu czas pojawienia się nowej próbki
   datetime barTime[1];

   //Kopiujemy do zmiennej czas pojawienia się nowej próbki
   barTime[0]=rates[0].time;
   //Jeśli czasy są takie same to nie mamy nowej próbki
   if(prevTime==barTime[0])
     {
      return;
     }
   //Zapisujemy czas pojawienia się próbki do zmiennej statycznej
   prevTime=barTime[0];
   
   //Sprawdzamy czy mamy otwartą pozycję
   bool buyOpened=false,sellOpened=false;

   if(PositionSelect(Expert.symbol)==true) //Jest otwarta pozycja
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         buyOpened=true;  //Jest to kupno
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         sellOpened=true; //Jest to sprzedaż
        }
     }
   //Zapisanie ceny zamknięcia próbki
   Expert.setPrice(rates[1].close);
   //Sprawdzamy czy można kupić
   Best.fillIndicatorsArrays(0);
   printf("Sprawdzanie możliwości kupna");
   if(Best.checkBuyRule(0,0)==true)
     {
      if(buyOpened)
        {
         Alert("We already have a Buy Position!!!");
         return;
        }
      double askPrice = NormalizeDouble(latestPrice.ask,_Digits);              //Aktualny ask
      double stl    = NormalizeDouble(latestPrice.ask - stp*_Point,_Digits); //Ustalenie wartości stop loss
      double tkp    = NormalizeDouble(latestPrice.ask + tkp*_Point,_Digits); //Ustalenie wartości take profit
      int    mdev   = 100;
      //Kupno
      Expert.openBuy(ORDER_TYPE_BUY,askPrice,stl,tkp,mdev);
     }
   //Sprawdzamy czy można sprzedać
   printf("Sprawdzanie możliwości sprzedaży");
   if(Best.checkSellRule(0,0)==true)
     {
      if(sellOpened)
        {
         Alert("We already have a Sell position!!!");
         return;
        }
      double bidPrice=NormalizeDouble(latestPrice.bid,_Digits);               //Aktualny bid
      double bstl    = NormalizeDouble(latestPrice.bid + stp*_Point,_Digits); // Stop Loss
      double btkp    = NormalizeDouble(latestPrice.bid - tkp*_Point,_Digits); // Take Profit
      int    bdev=100;
      //Sprzedaż
      Expert.openSell(ORDER_TYPE_SELL,bidPrice,bstl,btkp,bdev);
     }
return;
  }
