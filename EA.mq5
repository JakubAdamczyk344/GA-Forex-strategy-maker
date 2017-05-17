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
//Parametry wejściowe dla Expert Advisora
input int      StopLoss=30;      // Stop Loss
input int      TakeProfit=100;   // Take Profit
input int      ADX_Period=14;    // ADX Period
input int      MA_Period=10;     // Moving Average Period
input int      magicNumber=12345;   // EA Magic Number
input double   Adx_Min=22.0;     // Minimum ADX Value
input double   volume=0.2;          //Wolumen handlu
input int      checkMargin=0;     //Czy sprawdzać margines (0=No, 1=Yes)
input double   margin=15.0; //Procent wolnych środków

int stp,tkp;   //Zmienne pomocnicze do stop loss i take profit

//Utworzenie Expert Advisora
EAClass Expert;

int OnInit()
  {
   Expert.doInit(ADX_Period,MA_Period);
   Expert.setPeriod(_Period); //Ustawienie aktualnego okresu próbkowania
   Expert.setSymbol(_Symbol); //Ustawienie aktualnej pary walutowej
   Expert.setMagic(magicNumber);
   Expert.setadxmin(Adx_Min);
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
   Expert.doUninit();
  }
  
void OnTick()
  {
   //Sprwadzenie czy jest dostatecznie dużo próbek do handlu
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
   if(Expert.checkBuy()==true)
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
   if(Expert.checkSell()==true)
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
