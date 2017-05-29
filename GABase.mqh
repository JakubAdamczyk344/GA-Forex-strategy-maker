//+------------------------------------------------------------------+
//|                                                       GABase.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

class GABase
{
protected:
   //Wielkość populacji
   int popSize;
   //Para walut, na której gra expert advisor
   string symbol;
   //Okres, z jakim pobierane są informacje o cenach
   ENUM_TIMEFRAMES timeframe;
   //Cena (otwarcia, zamknięcia itp.), na podstawie której liczone są wartości wskaźników
   ENUM_APPLIED_PRICE  appliedPrice;
   //Zakres danych historycznych na temat pary walutowej (liczba próbek notowań, wartości wskaźników)
   int history;
   //Definicja osobnika
   struct individual
   {
      //Tablice przechowujące informacje o osobniku
      //Węzły drzewa (AND, OR, wskaźniki: MA,RSI,ADX,MACD)
      int tree[7];
      //Parametry wskaźnika MA
      int MAarray[6]; //MaPeriod
      //Parametry wskaźnika RSI
      int RSIarray[18]; //rsiPeriod, minRSI, maxRSI
      //Parametry wskaźnika ADX
      int ADXarray[12]; //adxPeriod, minADX
      //Parametry wskaźnika MACD
      int MACDarray[18]; //fastMA, slowMA, signalPeriod
      //Wartość funkcji przystosowania
      double fitness;
      //Zmienne pomocnicze wykorzystywane w selekcji
      double cfitness;
      double rfitness;   
   };
   //Uchwyty do wskaźników dla węzłów drzewa osobnika, które mogą zależeć od wskaźników
   int maHandleNode1;
   int adxHandleNode1;
   int macdHandleNode1;
   int rsiHandleNode1;
   
   int maHandleNode2;
   int adxHandleNode2;
   int macdHandleNode2;
   int rsiHandleNode2;
   
   int maHandleNode3;
   int adxHandleNode3;
   int macdHandleNode3;
   int rsiHandleNode3;
   
   int maHandleNode4;
   int adxHandleNode4;
   int macdHandleNode4;
   int rsiHandleNode4;
   
   int maHandleNode5;
   int adxHandleNode5;
   int macdHandleNode5;
   int rsiHandleNode5;
   
   int maHandleNode6;
   int adxHandleNode6;
   int macdHandleNode6;
   int rsiHandleNode6;
   //Definicja tablic przechowujących wartości wskaźnika MA
   double maValNode1[]; double maValNode2[]; double maValNode3[]; double maValNode4[]; double maValNode5[]; double maValNode6[];
   //Definicja tablic przechowujących wartości wskaźnika ADX
   double adxValNode1[];   double adxValNode2[];   double adxValNode3[];   double adxValNode4[];   double adxValNode5[];   double adxValNode6[];
   //Definicja tablic przechowujących wartości linii plus DI wskaźnika ADX
   double plsDINode1[]; double plsDINode2[]; double plsDINode3[]; double plsDINode4[]; double plsDINode5[]; double plsDINode6[];
   //Definicja tablic przechowujących wartości linii minus DI wskaźnika ADX
   double minDINode1[]; double minDINode2[]; double minDINode3[]; double minDINode4[]; double minDINode5[]; double minDINode6[];
   //Definicja tablic przechowujących wartości linii głównej wskaźnika MACD
   double mainLineNode1[]; double mainLineNode2[]; double mainLineNode3[]; double mainLineNode4[]; double mainLineNode5[]; double mainLineNode6[];
   //Definicja tablic przechowujących wartości linii sygnałowej wskaźnika MACD
   double signalLineNode1[];  double signalLineNode2[];  double signalLineNode3[];  double signalLineNode4[];  double signalLineNode5[];  double signalLineNode6[];
   //Definicja tablic przechowujących wartości wskaźnika RSI
   double rsiValNode1[];   double rsiValNode2[];   double rsiValNode3[];   double rsiValNode4[];   double rsiValNode5[];   double rsiValNode6[];
   //Definicja struktry przechowującej dane o parze walutowej (między innymi kurs otwarcia, zamknięcia itp.)
   MqlRates price[];
   //Definicja reguł kupna
   //Deklaracja reguł kupna drugiego poziomu drzewa decyzyjnego
   bool lvl2BuyRule1;
   bool lvl2BuyRule2;
   bool lvl2BuyRule3;
   bool lvl2BuyRule4;
   //Deklaracja reguł kupna pierwszego poziomu drzewa decyzyjnego
   bool lvl1BuyRule1;
   bool lvl1BuyRule2;
   //Deklaracja reguły kupna zerowego poziomu drzewa decyzyjnego - warunku kupna
   bool buyRule;
   
   //Definicja reguł sprzedaży
   //Deklaracja reguł sprzedaży drugiego poziomu drzewa decyzyjnego
   bool lvl2SellRule1;
   bool lvl2SellRule2;
   bool lvl2SellRule3;
   bool lvl2SellRule4;
   //Deklaracja reguł sprzedaży pierwszego poziomu drzewa decyzyjnego
   bool lvl1SellRule1;
   bool lvl1SellRule2;
   //Deklaracja reguły sprzedaży zerowego poziomu drzewa decyzyjnego - warunku kupna
   bool sellRule;
   
public:
   //Definicja tablicy przechowującej populację
   individual population[];
   //Konstruktor
   GABase();
   //Destruktor
   ~GABase();
   //Metoda tworząca i sprawdzająca regułę kupna
   bool checkBuyRule(int whichIndividual, int i);
   //Metoda tworząca i sprawdzająca regułę sprzedaży
   bool checkSellRule(int whichIndividual, int i);
   //Metoda zapisująca wartości wskaźników do tablic w zależności od parametrów danego osobnika
   void fillIndicatorsArrays(int whichIndividual);
};

GABase::GABase()
  {
      //ustalenie parametrów AG
      popSize = 1;
      symbol = "EURUSD";
      appliedPrice = PRICE_CLOSE;
      timeframe = PERIOD_M1;
      history = 3;
      //Utworzenie tablicy przechowującej populację
      ArrayResize(population,popSize);
      //Pobranie informacji na temat cen z danego okresu (wykorzystywane do analizy wskażnika MA i do oceny osobników)
      CopyRates(symbol,timeframe,0,history,price);
  }
  
GABase::~GABase()
  {
  }
  
bool GABase::checkBuyRule(int whichIndividual, int i)
{
   //Tworzenie reguły kupna
   //Reguły drugiego poziomu
   //Reguła pierwsza drugiego poziomu - generowana w zależności od wartości trzeciej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[3])
   {
      case 1: lvl2BuyRule1 = (((maValNode3[i] > maValNode3[i+1]) && (maValNode3[i+1] > maValNode3[i+2])) && (price[i+1].close > maValNode3[i+1])); break;
      case 2: lvl2BuyRule1 = ((rsiValNode3[i+1] > population[whichIndividual].RSIarray[7]) && (rsiValNode3[i] < population[whichIndividual].RSIarray[7])); break;
      case 3: lvl2BuyRule1 = ((adxValNode3[i] > population[whichIndividual].ADXarray[5]) && (plsDINode3[i] > minDINode3[i])); break;
      case 4: lvl2BuyRule1 = ((mainLineNode3[i+1] > signalLineNode3[i+1]) && (mainLineNode3[i] < signalLineNode3[i])); break;
   }
   //Reguła druga drugiego poziomu - generowana w zależności od wartości czwartej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[4])
   {
      case 1: lvl2BuyRule2 = (((maValNode4[i] > maValNode4[i+1]) && (maValNode4[i+1] > maValNode4[i+2])) && (price[i+1].close > maValNode4[i+1])); break;
      case 2: lvl2BuyRule2 = ((rsiValNode4[i+1] > population[whichIndividual].RSIarray[10]) && (rsiValNode4[i] < population[whichIndividual].RSIarray[10])); break;
      case 3: lvl2BuyRule2 = ((adxValNode4[i] > population[whichIndividual].ADXarray[7]) && (plsDINode4[i] > minDINode4[i])); break;
      case 4: lvl2BuyRule2 = ((mainLineNode4[i+1] > signalLineNode4[i+1]) && (mainLineNode4[i] < signalLineNode4[i])); break;
   }
   //Reguła trzecia drugiego poziomu - generowana w zależności od wartości piątej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[5])
   {
      case 1: lvl2BuyRule3 = (((maValNode5[i] > maValNode5[i+1]) && (maValNode5[i+1] > maValNode5[i+2])) && (price[i+1].close > maValNode5[i+1])); break;
      case 2: lvl2BuyRule3 = ((rsiValNode5[i+1] > population[whichIndividual].RSIarray[13]) && (rsiValNode5[i] < population[whichIndividual].RSIarray[13])); break;
      case 3: lvl2BuyRule3 = ((adxValNode5[i] > population[whichIndividual].ADXarray[9]) && (plsDINode5[i] > minDINode5[i])); break;
      case 4: lvl2BuyRule3 = ((mainLineNode5[i+1] > signalLineNode5[i+1]) && (mainLineNode5[i] < signalLineNode5[i])); break;
   }
   //Reguła czwarta drugiego poziomu - generowana w zależności od wartości szóstej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[6])
   {
      case 1: lvl2BuyRule4 = (((maValNode6[i] > maValNode6[i+1]) && (maValNode6[i+1] > maValNode6[i+2])) && (price[i+1].close > maValNode6[i+1])); break;
      case 2: lvl2BuyRule4 = ((rsiValNode6[i+1] > population[whichIndividual].RSIarray[16]) && (rsiValNode6[i] < population[whichIndividual].RSIarray[16])); break;
      case 3: lvl2BuyRule4 = ((adxValNode6[i] > population[whichIndividual].ADXarray[11]) && (plsDINode6[i] > minDINode6[i])); break;
      case 4: lvl2BuyRule4 = ((mainLineNode6[i+1] > signalLineNode6[i+1]) && (mainLineNode6[i] < signalLineNode6[i])); break;
   }
   //Reguły pierwszego poziomu
   //Reguła pierwsza pierwszego poziomu - generowana w zależności od wartości pierwszej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[1])
   {
      case 1: lvl1BuyRule1 = lvl2BuyRule1 || lvl2BuyRule2; break;
      case 2: lvl1BuyRule1 = lvl2BuyRule1 || lvl2BuyRule2; break;
      case 3: lvl1BuyRule1 = lvl2BuyRule1 && lvl2BuyRule2; break;
      case 4: lvl1BuyRule1 = lvl2BuyRule1 && lvl2BuyRule2; break;
      case 5: lvl1BuyRule1 = (((maValNode1[i] > maValNode1[i+1]) && (maValNode1[i+1] > maValNode1[i+2])) && (price[i+1].close > maValNode1[i+1])); break;
      case 6: lvl1BuyRule1 = ((rsiValNode1[i+1] > population[whichIndividual].RSIarray[1]) && (rsiValNode1[i] < population[whichIndividual].RSIarray[1])); break;
      case 7: lvl1BuyRule1 = ((adxValNode1[i] > population[whichIndividual].ADXarray[1]) && (plsDINode1[i] > minDINode1[i])); break;
      case 8: lvl1BuyRule1 = ((mainLineNode1[i+1] > signalLineNode1[i+1]) && (mainLineNode1[i] < signalLineNode1[i])); break;
   }
   //Reguła druga pierwszego poziomu - generowana w zależności od wartości drgiej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[2])
   {
      case 1: lvl1BuyRule2 = lvl2BuyRule1 || lvl2BuyRule2; break;
      case 2: lvl1BuyRule2 = lvl2BuyRule1 || lvl2BuyRule2; break;
      case 3: lvl1BuyRule2 = lvl2BuyRule1 && lvl2BuyRule2; break;
      case 4: lvl1BuyRule2 = lvl2BuyRule1 && lvl2BuyRule2; break;
      case 5: lvl1BuyRule2 = (((maValNode2[i] > maValNode2[i+1]) && (maValNode1[i+1] > maValNode2[i+2])) && (price[i+1].close > maValNode2[i+1])); break;
      case 6: lvl1BuyRule2 = ((rsiValNode2[i+1] > population[whichIndividual].RSIarray[4]) && (rsiValNode2[i] < population[whichIndividual].RSIarray[4])); break;
      case 7: lvl1BuyRule2 = ((adxValNode2[i] > population[whichIndividual].ADXarray[3]) && (plsDINode2[i] > minDINode2[i])); break;
      case 8: lvl1BuyRule2 = ((mainLineNode2[i+1] > signalLineNode2[i+1]) && (mainLineNode2[i] < signalLineNode2[i])); break;
   }
   //Reguła zerowego poziomu - generowana w zaleźnosci od wartości zerowej "szufladki"tablicy drzewa decyzyjnego
   switch (population[whichIndividual].tree[0])
   {
      case 1: buyRule = lvl1BuyRule1 || lvl1BuyRule2; break;
      case 2: buyRule = lvl1BuyRule1 && lvl1BuyRule2; break;
   }
   //Sprawdzenie czy reguła kupna spełniona, jeśli tak to zwrócić true
   if (buyRule == true) {return true;}
   else {return false;}
}

bool GABase::checkSellRule(int whichIndividual, int i)
{   
   //Tworzenie reguły sprzedaży
   //Reguły drugiego poziomu
   //Reguła pierwsza drugiego poziomu - generowana w zależności od wartości trzeciej "szufladki" tablicy z drzewem decyzyjnym   
   switch (population[whichIndividual].tree[3])
   {
      case 1: lvl2SellRule1 = (((maValNode3[i] < maValNode3[i+1]) && (maValNode3[i+1] < maValNode3[i+2])) && (price[i+1].close < maValNode3[i+1])); break;
      case 2: lvl2SellRule1 = ((rsiValNode3[i+1] < population[whichIndividual].RSIarray[8]) && (rsiValNode3[i] > population[whichIndividual].RSIarray[8])); break;
      case 3: lvl2SellRule1 = ((adxValNode3[i] > population[whichIndividual].ADXarray[5]) && (plsDINode3[i] < minDINode3[i])); break;
      case 4: lvl2SellRule1 = ((mainLineNode3[i+1] < signalLineNode3[i+1]) && (mainLineNode3[i] > signalLineNode3[i])); break;
      case 5: printf("Wezel drzewa ma inny numer niz mozliwy z losowania"); break;
   }
   //Reguła druga drugiego poziomu - generowana w zależności od wartości czwartej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[4])
   {
      case 1: lvl2SellRule2 = (((maValNode4[i] < maValNode4[i+1]) && (maValNode4[i+1] < maValNode4[i+2])) && (price[i+1].close < maValNode4[i+1])); break;
      case 2: lvl2SellRule2 = ((rsiValNode4[i+1] < population[whichIndividual].RSIarray[11]) && (rsiValNode4[i] > population[whichIndividual].RSIarray[11])); break;
      case 3: lvl2SellRule2 = ((adxValNode4[i] > population[whichIndividual].ADXarray[7]) && (plsDINode4[i] < minDINode4[i])); break;
      case 4: lvl2SellRule2 = ((mainLineNode4[i+1] < signalLineNode4[i+1]) && (mainLineNode4[i] > signalLineNode4[i])); break;
   }
   //Reguła trzecia drugiego poziomu - generowana w zależności od wartości piątej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[5])
   {
      case 1: lvl2SellRule3 = (((maValNode5[i] < maValNode5[i+1]) && (maValNode5[i+1] < maValNode5[i+2])) && (price[i+1].close < maValNode5[i+1])); break;
      case 2: lvl2SellRule3 = ((rsiValNode5[i+1] < population[whichIndividual].RSIarray[14]) && (rsiValNode5[i] > population[whichIndividual].RSIarray[14])); break;
      case 3: lvl2SellRule3 = ((adxValNode5[i] > population[whichIndividual].ADXarray[9]) && (plsDINode5[i] < minDINode5[i])); break;
      case 4: lvl2SellRule3 = ((mainLineNode5[i+1] < signalLineNode5[i+1]) && (mainLineNode5[i] > signalLineNode5[i])); break;
   }
   //Reguła czwarta drugiego poziomu - generowana w zależności od wartości szóstej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[6])
   {
      case 1: lvl2SellRule4 = (((maValNode6[i] < maValNode6[i+1]) && (maValNode6[i+1] < maValNode6[i+2])) && (price[i+1].close < maValNode6[i+1])); break;
      case 2: lvl2SellRule4 = ((rsiValNode6[i+1] < population[whichIndividual].RSIarray[17]) && (rsiValNode6[i] > population[whichIndividual].RSIarray[17])); break;
      case 3: lvl2SellRule4 = ((adxValNode6[i] > population[whichIndividual].ADXarray[11]) && (plsDINode6[i] < minDINode6[i])); break;
      case 4: lvl2SellRule4 = ((mainLineNode6[i+1] < signalLineNode6[i+1]) && (mainLineNode6[i] > signalLineNode6[i])); break;
   }
   //Reguły pierwszego poziomu
   //Reguła pierwsza pierwszego poziomu - generowana w zależności od wartości pierwszej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[1])
   {
      case 1: lvl1SellRule1 = lvl2SellRule1 || lvl2SellRule2; break;
      case 2: lvl1SellRule1 = lvl2SellRule1 || lvl2SellRule2; break;
      case 3: lvl1SellRule1 = lvl2SellRule1 && lvl2SellRule2; break;
      case 4: lvl1SellRule1 = lvl2SellRule1 && lvl2SellRule2; break;
      case 5: lvl1SellRule1 = (((maValNode1[i] < maValNode1[i+1]) && (maValNode1[i+1] < maValNode1[i+2])) && (price[i+1].close < maValNode1[i+1])); break;
      case 6: lvl1SellRule1 = ((rsiValNode1[i+1] < population[whichIndividual].RSIarray[2]) && (rsiValNode1[i] > population[whichIndividual].RSIarray[2])); break;
      case 7: lvl1SellRule1 = ((adxValNode1[i] > population[whichIndividual].ADXarray[1]) && (plsDINode1[i] < minDINode1[i])); break;
      case 8: lvl1SellRule1 = ((mainLineNode1[i+1] < signalLineNode1[i+1]) && (mainLineNode1[i] > signalLineNode1[i])); break;
   }
   //Reguła druga pierwszego poziomu - generowana w zależności od wartości drgiej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[2])
   {
      case 1: lvl1SellRule2 = lvl2SellRule1 || lvl2SellRule2; break;
      case 2: lvl1SellRule2 = lvl2SellRule1 || lvl2SellRule2; break;
      case 3: lvl1SellRule2 = lvl2SellRule1 && lvl2SellRule2; break;
      case 4: lvl1SellRule2 = lvl2SellRule1 && lvl2SellRule2; break;
      case 5: lvl1SellRule2 = (((maValNode2[i] < maValNode2[i+1]) && (maValNode2[i+1] < maValNode2[i+2])) && (price[i+1].close < maValNode2[i+1])); break;
      case 6: lvl1SellRule2 = ((rsiValNode2[i+1] < population[whichIndividual].RSIarray[5]) && (rsiValNode2[i] > population[whichIndividual].RSIarray[5])); break;
      case 7: lvl1SellRule2 = ((adxValNode2[i] > population[whichIndividual].ADXarray[3]) && (plsDINode2[i] < minDINode2[i])); break;
      case 8: lvl1SellRule2 = ((mainLineNode2[i+1] < signalLineNode2[i+1]) && (mainLineNode2[i] > signalLineNode2[i])); break;
   }
   //Reguła zerowego poziomu - generowana w zaleźnosci od wartości zerowej "szufladki"tablicy drzewa decyzyjnego
   switch (population[whichIndividual].tree[0])
   {
      case 1: sellRule = lvl1SellRule1 || lvl1SellRule2; break;
      case 2: sellRule = lvl1SellRule1 && lvl1SellRule2; break;
   }
   //Sprawdzenie czy reguła sprzedaży spełniona, jeśli tak to zwrócić true
   if (sellRule == true) {return true;}
   else {return false;}
}

void GABase::fillIndicatorsArrays(int whichIndividual)
{
   //Utworzenie uchwytów do wskaźników
   maHandleNode1 = iMA(symbol,timeframe,population[whichIndividual].MAarray[0],0,MODE_SMA,appliedPrice);
   adxHandleNode1 = iADX(symbol,timeframe,population[whichIndividual].ADXarray[0]);
   macdHandleNode1 = iMACD(symbol,timeframe,population[whichIndividual].MACDarray[0],population[whichIndividual].MACDarray[1],population[whichIndividual].MACDarray[2],appliedPrice);
   rsiHandleNode1 = iRSI(symbol,timeframe,population[whichIndividual].RSIarray[0],appliedPrice);
   
   maHandleNode2 = iMA(symbol,timeframe,population[whichIndividual].MAarray[1],0,MODE_SMA,appliedPrice);
   adxHandleNode2 = iADX(symbol,timeframe,population[whichIndividual].ADXarray[2]);
   macdHandleNode2 = iMACD(symbol,timeframe,population[whichIndividual].MACDarray[3],population[whichIndividual].MACDarray[4],population[whichIndividual].MACDarray[5],appliedPrice);
   rsiHandleNode2 = iRSI(symbol,timeframe,population[whichIndividual].RSIarray[3],appliedPrice);
   
   maHandleNode3 = iMA(symbol,timeframe,population[whichIndividual].MAarray[2],0,MODE_SMA,appliedPrice);
   adxHandleNode3 = iADX(symbol,timeframe,population[whichIndividual].ADXarray[4]);
   macdHandleNode3 = iMACD(symbol,timeframe,population[whichIndividual].MACDarray[6],population[whichIndividual].MACDarray[7],population[whichIndividual].MACDarray[8],appliedPrice);
   rsiHandleNode3 = iRSI(symbol,timeframe,population[whichIndividual].RSIarray[6],appliedPrice);
   
   maHandleNode4 = iMA(symbol,timeframe,population[whichIndividual].MAarray[3],0,MODE_SMA,appliedPrice);
   adxHandleNode4 = iADX(symbol,timeframe,population[whichIndividual].ADXarray[6]);
   macdHandleNode4 = iMACD(symbol,timeframe,population[whichIndividual].MACDarray[9],population[whichIndividual].MACDarray[10],population[whichIndividual].MACDarray[11],appliedPrice);
   rsiHandleNode4 = iRSI(symbol,timeframe,population[whichIndividual].RSIarray[9],appliedPrice);
   
   maHandleNode5 = iMA(symbol,timeframe,population[whichIndividual].MAarray[4],0,MODE_SMA,appliedPrice);
   adxHandleNode5 = iADX(symbol,timeframe,population[whichIndividual].ADXarray[8]);
   macdHandleNode5 = iMACD(symbol,timeframe,population[whichIndividual].MACDarray[12],population[whichIndividual].MACDarray[13],population[whichIndividual].MACDarray[14],appliedPrice);
   rsiHandleNode5 = iRSI(symbol,timeframe,population[whichIndividual].RSIarray[12],appliedPrice);
   
   maHandleNode6 = iMA(symbol,timeframe,population[whichIndividual].MAarray[5],0,MODE_SMA,appliedPrice);
   adxHandleNode6 = iADX(symbol,timeframe,population[whichIndividual].ADXarray[10]);
   macdHandleNode6 = iMACD(symbol,timeframe,population[whichIndividual].MACDarray[15],population[whichIndividual].MACDarray[16],population[whichIndividual].MACDarray[17],appliedPrice);
   rsiHandleNode6 = iRSI(symbol,timeframe,population[whichIndividual].RSIarray[15],appliedPrice);
      
   //Wypełnienie tablic z wartościami wskaźników
   //Zgodnie z założeniem Expert grać będzie krótkoterminowo więc dane z dwóch tygodni powinny wystarczyć
   CopyBuffer(maHandleNode1,0,0,history,maValNode1); CopyBuffer(maHandleNode2,0,0,history,maValNode2); CopyBuffer(maHandleNode3,0,0,history,maValNode3);
   CopyBuffer(maHandleNode4,0,0,history,maValNode4); CopyBuffer(maHandleNode5,0,0,history,maValNode5); CopyBuffer(maHandleNode6,0,0,history,maValNode6);
    
   CopyBuffer(adxHandleNode1,0,0,history,adxValNode1);  CopyBuffer(adxHandleNode2,0,0,history,adxValNode2);  CopyBuffer(adxHandleNode3,0,0,history,adxValNode3);
   CopyBuffer(adxHandleNode4,0,0,history,adxValNode4);  CopyBuffer(adxHandleNode5,0,0,history,adxValNode5);  CopyBuffer(adxHandleNode6,0,0,history,adxValNode6);
   
   CopyBuffer(adxHandleNode1,1,0,history,plsDINode1);   CopyBuffer(adxHandleNode2,1,0,history,plsDINode2);   CopyBuffer(adxHandleNode3,1,0,history,plsDINode3);
   CopyBuffer(adxHandleNode4,1,0,history,plsDINode4);   CopyBuffer(adxHandleNode5,1,0,history,plsDINode5);   CopyBuffer(adxHandleNode6,1,0,history,plsDINode6);
   
   CopyBuffer(adxHandleNode1,2,0,history,minDINode1);   CopyBuffer(adxHandleNode2,2,0,history,minDINode2);   CopyBuffer(adxHandleNode3,2,0,history,minDINode3);
   CopyBuffer(adxHandleNode4,2,0,history,minDINode4);   CopyBuffer(adxHandleNode5,2,0,history,minDINode5);   CopyBuffer(adxHandleNode6,2,0,history,minDINode6);
   
   CopyBuffer(macdHandleNode1,0,0,history,mainLineNode1);  CopyBuffer(macdHandleNode2,0,0,history,mainLineNode2);  CopyBuffer(macdHandleNode3,0,0,history,mainLineNode3);
   CopyBuffer(macdHandleNode4,0,0,history,mainLineNode4);  CopyBuffer(macdHandleNode5,0,0,history,mainLineNode5);  CopyBuffer(macdHandleNode6,0,0,history,mainLineNode6);
   
   CopyBuffer(macdHandleNode1,1,0,history,signalLineNode1);   CopyBuffer(macdHandleNode2,1,0,history,signalLineNode2);   CopyBuffer(macdHandleNode3,1,0,history,signalLineNode3);
   CopyBuffer(macdHandleNode4,1,0,history,signalLineNode4);   CopyBuffer(macdHandleNode5,1,0,history,signalLineNode5);   CopyBuffer(macdHandleNode6,1,0,history,signalLineNode6);
   
   CopyBuffer(rsiHandleNode1,0,0,history,rsiValNode1);  CopyBuffer(rsiHandleNode2,0,0,history,rsiValNode2);  CopyBuffer(rsiHandleNode3,0,0,history,rsiValNode3);
   CopyBuffer(rsiHandleNode4,0,0,history,rsiValNode4);  CopyBuffer(rsiHandleNode5,0,0,history,rsiValNode5);  CopyBuffer(rsiHandleNode6,0,0,history,rsiValNode6);
}