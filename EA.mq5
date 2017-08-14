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
#include <CallGA.mqh>

//Parametry wejściowe dla Expert Advisora
input int      StopLoss=30;      // Stop Loss
input int      TakeProfit=100;   // Take Profit
input int      magicNumber=12345;   // EA Magic Number
input double   volume=0.1;          //Wolumen handlu
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
Best.population[0].tree[0] = 2;
Best.population[0].tree[1] = 1;
Best.population[0].tree[2] = 7;
Best.population[0].tree[3] = 2;
Best.population[0].tree[4] = 4;
Best.population[0].tree[5] = 2;
Best.population[0].tree[6] = 2;
Best.population[0].MAarray[0] = 12;
Best.population[0].MAarray[1] = 12;
Best.population[0].MAarray[2] = 6;
Best.population[0].MAarray[3] = 5;
Best.population[0].MAarray[4] = 9;
Best.population[0].MAarray[5] = 12;
Best.population[0].ADXarray[0] = 12;
Best.population[0].ADXarray[1] = 21;
Best.population[0].ADXarray[2] = 15;
Best.population[0].ADXarray[3] = 24;
Best.population[0].ADXarray[4] = 5;
Best.population[0].ADXarray[5] = 26;
Best.population[0].ADXarray[6] = 9;
Best.population[0].ADXarray[7] = 23;
Best.population[0].ADXarray[8] = 9;
Best.population[0].ADXarray[9] = 23;
Best.population[0].ADXarray[10] = 5;
Best.population[0].ADXarray[11] = 29;
Best.population[0].RSIarray[0] = 11;
Best.population[0].RSIarray[1] = 28;
Best.population[0].RSIarray[2] = 72;
Best.population[0].RSIarray[3] = 5;
Best.population[0].RSIarray[4] = 23;
Best.population[0].RSIarray[5] = 76;
Best.population[0].RSIarray[6] = 12;
Best.population[0].RSIarray[7] = 22;
Best.population[0].RSIarray[8] = 73;
Best.population[0].RSIarray[9] = 12;
Best.population[0].RSIarray[10] = 27;
Best.population[0].RSIarray[11] = 77;
Best.population[0].RSIarray[12] = 11;
Best.population[0].RSIarray[13] = 23;
Best.population[0].RSIarray[14] = 78;
Best.population[0].RSIarray[15] = 7;
Best.population[0].RSIarray[16] = 28;
Best.population[0].RSIarray[17] = 76;
Best.population[0].MACDarray[0] = 15;
Best.population[0].MACDarray[1] = 28;
Best.population[0].MACDarray[2] = 10;
Best.population[0].MACDarray[3] = 11;
Best.population[0].MACDarray[4] = 28;
Best.population[0].MACDarray[5] = 9;
Best.population[0].MACDarray[6] = 13;
Best.population[0].MACDarray[7] = 23;
Best.population[0].MACDarray[8] = 9;
Best.population[0].MACDarray[9] = 12;
Best.population[0].MACDarray[10] = 28;
Best.population[0].MACDarray[11] = 10;
Best.population[0].MACDarray[12] = 16;
Best.population[0].MACDarray[13] = 24;
Best.population[0].MACDarray[14] = 7;
Best.population[0].MACDarray[15] = 15;
Best.population[0].MACDarray[16] = 28;
Best.population[0].MACDarray[17] = 8;

   Expert.setPeriod(PERIOD_M1); //Ustawienie okresu próbkowania
   Expert.setSymbol("EURUSD"); //Ustawienie pary walutowej
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
   if(buyOpened)
      {
         Alert("We already have a Buy Position!!!");
         return;
      }
      printf("Sprawdzanie możliwości kupna");
      if(Best.checkBuyRule(0,0)==true)
      {
         double askPrice = NormalizeDouble(latestPrice.ask,_Digits);              //Aktualny ask
         double stl    = NormalizeDouble(latestPrice.ask - stp*_Point,_Digits); //Ustalenie wartości stop loss
         double tkp    = NormalizeDouble(latestPrice.ask + tkp*_Point,_Digits); //Ustalenie wartości take profit
         int    mdev   = 100;
         //Kupno
         Expert.openBuy(ORDER_TYPE_BUY,askPrice,stl,tkp,mdev);
      }
   //Sprawdzamy czy można sprzedać
   if(sellOpened)
      {
         Alert("We already have a Sell position!!!");
         return;
      }
      printf("Sprawdzanie możliwości sprzedaży");
      if(Best.checkSellRule(0,0)==true)
      {
         double bidPrice=NormalizeDouble(latestPrice.bid,_Digits);               //Aktualny bid
         double bstl    = NormalizeDouble(latestPrice.bid + stp*_Point,_Digits); // Stop Loss
         double btkp    = NormalizeDouble(latestPrice.bid - tkp*_Point,_Digits); // Take Profit
         int    bdev=100;
         //Sprzedaż
         Expert.openSell(ORDER_TYPE_SELL,bidPrice,bstl,btkp,bdev);
      }
   return;
   }
