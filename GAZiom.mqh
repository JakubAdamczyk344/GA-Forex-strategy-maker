//+------------------------------------------------------------------+
//|                                                       GAZiom.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class GAZiom
{
protected:
   //Wielkość populacji
   int popSize;
   //Liczba generacji
   int nGen;
   //Prawdopodobieństwo krzyżowania
   float pCross;
   //Prawdopodobieństwo mutacji
   float pMut;
   //Para walut, na której gra expert advisor
   string symbol;
   //Okres, z jakim pobierane są informacje o cenach
   ENUM_TIMEFRAMES timeframe;
   //Cena (otwarcia, zamknięcia itp.), na podstawie której liczone są wartości wskaźników
   ENUM_APPLIED_PRICE  appliedPrice;
   /*//Okres liczenia wskażnika MA
   int maPeriod;
   //Okres liczenia wskaźnika ADX
   int adxPeriod;
   //Sygnał minimum wskaźnika ADX
   int minADX;
   //Okres liczenia wskaźnika RSI
   int rsiPeriod;
   //Sygnał minimum wskaźnika RSI
   int minRSI;
   //Sygnał maksimum wskaźnika RSI
   int maxRSI;
   //Okres szybkiej MA dla wskaźnika MACD
   int fastMA;
   //Okres wolnej MA dla wskaźnika MACD
   int slowMA;
   //Okres linii sygnałowej wskaźnika MACD
   int signalPeriod;*/
   
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
      //Parametry wskaźnika MAXD
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
   //Definicja tablicy przechowującej populację
   individual population[];
   //Definicja tablicy przechowującej nową populację
   individual newPopulation[];
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
      //Konstruktor
      GAZiom();
      //Destruktor
      ~GAZiom();
      //Metoda zwracająca liczbę pseudolosową z podanego zakresu min - max
      int randomValue(int min, int max);
      //Metoda tworząca populację początkową
      void initialization();
      //Metoda tworząca i sprawdzająca regułę kupna
      bool checkBuyRule(int whichIndividual, int i);
      //Metoda tworząca i sprawdzająca regułę sprzedaży
      bool checkSellRule(int whichIndividual, int i);
      //Metoda zapisująca wartości wskaźników do tablic w zależności od parametrów danego osobnika
      void fillIndicatorsArrays(int whichIndividual);
      //Metoda dokonująca oceny każdego osobnika populacji
      void evaluation();
      //Metoda zachowująca najlepszego osobika populacji
      void keepTheBest();
      //Metoda dokonująca selekcji osobników do krzyżowania i mutacji
      void selection();
      //Metoda krzyżująca wybrane osobniki
      void cross(int firstInd, int secondInd);
      //Metoda wybierająca osobniki do krzyżowania
      void crossover();
      //Metoda mutująca wybranego osobnika
      void mutation();
      //Metoda implementująca mechanizm elityzmu
      void elitism();
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GAZiom::GAZiom()
  {
      //ustalenie parametrów AG
      popSize = 50;
      nGen = 1000;
      pCross = 0.5;
      pMut = 0.1;
      symbol = "EURUSD";
      appliedPrice = PRICE_CLOSE;
      timeframe = PERIOD_M1;
      //Utworzenie tablicy przechowującej populację
      ArrayResize(population,popSize+1);
      //Utworzenie tablicy przechowującej nową populację
      ArrayResize(newPopulation,popSize+1);
      //Pobranie informacji na temat cen z danego okresu (wykorzystywane do analizy wskażnika MA i do oceny osobników)
      CopyRates(symbol,timeframe,0,10080,price);
  }

GAZiom::~GAZiom()
  {
  }

int GAZiom::randomValue(int min, int max)
{
	//MathSrand(GetTickCount());
	double random = MathRand()%10;
	return MathRound((random/9*(max - min))+min);
}

void GAZiom::initialization(void)
{
   //Iteracja po każdym osobniku populacji
   for (int i = 0; i < popSize; i++)
	{
	   //Tworzenie drzewa osobnika
	   population[i].tree[0] = randomValue(1,2);
		population[i].tree[1] = randomValue(1,8);
		population[i].tree[2] = randomValue(1,8);
		//Sprawdzenie czy węzeł 1 jest OR lub AND - wtedy wylosować wskaźniki do kolejnych węzłów
		if ((population[i].tree[1] >= 1) && (population[i].tree[1] >= 4))
		{
		   population[i].tree[3] = randomValue(1,4);
		   population[i].tree[4] = randomValue(1,4);
		}
		//Sprawdzenie czy węzeł 2 jest OR lub AND - wtedy wylosować wskaźniki do kolejnych węzłów
		if ((population[i].tree[2] >= 1) && (population[i].tree[2] >= 4))
		{
		   population[i].tree[5] = randomValue(1,4);
		   population[i].tree[6] = randomValue(1,4);
		}
		
		//Losowanie wartości parametrów wskaźnika MA dla węzłów 1 - 6
		//Losowanie maPeriod
		for (int j = 0; j < 6; j++)
		{
		   population[i].MAarray[j] = randomValue(5,15);
		}
		
		//Losowanie wartości parametrów wskaźnika RSI dla węzłów 1 - 6
		//Losowanie rsiPeriod
		for (int j = 0; j < 16; j+=3)
		{
		   population[i].RSIarray[j] = randomValue(5,15);
		}
		//Losowanie minRSI
		for (int j = 1; j < 17; j+=3)
		{
		   population[i].RSIarray[j] = randomValue(20,30);
		}
		//Losowanie maxRSI
		for (int j = 2; j < 18; j+=3)
		{
		   population[i].RSIarray[j] = randomValue(70,80);
		}
		
		//Losowanie wartości parametrów wskaźnika ADX dla węzłów 1 - 6
		//Losowanie adxPeriod
		for (int j = 0; j < 11; j+=2)
		{
		   population[i].ADXarray[j] = randomValue(5,15);
		}
		//Losowanie minADX
		for (int j = 1; j < 12; j+=2)
		{
		   population[i].ADXarray[j] = randomValue(20,30);
		}
		
		//Losowanie wartości parametrów wskaźnika MACD dla węzłów 1 - 6
		//Losowanie fastMA
		for (int j = 0; j < 16; j+=3)
		{
		   population[i].MACDarray[j] = randomValue(10,16);
		}
		//Losowanie slowMA
		for (int j = 1; j < 17; j+=3)
		{
		   population[i].MACDarray[j] = randomValue(23,29);
		}
		//Losowanie signalPerid
		for (int j = 2; j < 18; j+=3)
		{
		   population[i].MACDarray[j] = randomValue(7,10);
		}
   }
}

bool GAZiom::checkBuyRule(int whichIndividual, int i)
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
   
bool GAZiom::checkSellRule(int whichIndividual, int i)
{   
   //Tworzenie reguły sprzedaży
   //Reguły drugiego poziomu
   //Reguła pierwsza drugiego poziomu - generowana w zależności od wartości trzeciej "szufladki" tablicy z drzewem decyzyjnym
   
      /*case 1: lvl2SellRule1 = (((maVal[i] > maVal[i+1]) && (maVal[i+1] > maVal[i+2])) && (price[i+1].close > maVal[i+1])); break;
      case 2: lvl2SellRule1 = ((rsiVal[i+1] > minRSI) && (rsiVal[i] < minRSI)); break;
      case 3: lvl2SellRule1 = ((adxVal[i] > minADX) && (plsDI[i] < minDI[i])); break;
      case 4: lvl2SellRule1 = ((mainLine[i+1] > signalLine[i+1]) && (mainLine[i] < mainLine[i])); break;*/
      
   //Reguła pierwsza drugiego poziomu - generowana w zależności od wartości trzeciej "szufladki" tablicy z drzewem decyzyjnym   
   switch (population[whichIndividual].tree[3])
   {
      case 1: lvl2SellRule1 = (((maValNode3[i] < maValNode3[i+1]) && (maValNode3[i+1] < maValNode3[i+2])) && (price[i+1].close < maValNode3[i+1])); break;
      case 2: lvl2SellRule1 = ((rsiValNode3[i+1] < population[whichIndividual].RSIarray[8]) && (rsiValNode3[i] > population[whichIndividual].RSIarray[8])); break;
      case 3: lvl2SellRule1 = ((adxValNode3[i] > population[whichIndividual].ADXarray[5]) && (plsDINode3[i] < minDINode3[i])); break;
      case 4: lvl2SellRule1 = ((mainLineNode3[i+1] < signalLineNode3[i+1]) && (mainLineNode3[i] > signalLineNode3[i])); break;
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

void GAZiom::fillIndicatorsArrays(int whichIndividual)
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
   //Wybrano liczbę wartości do pobrania jako 10080 bo przy docelowym okresie zbierania danych 1 min będzie to 2 tygodnie
   //Zgodnie z założeniem Expert grać będzie krótkoterminowo więc dane z dwóch tygodni powinny wystarczyć
   CopyBuffer(maHandleNode1,0,0,10080,maValNode1); CopyBuffer(maHandleNode2,0,0,10080,maValNode2); CopyBuffer(maHandleNode3,0,0,10080,maValNode3);
   CopyBuffer(maHandleNode4,0,0,10080,maValNode4); CopyBuffer(maHandleNode5,0,0,10080,maValNode5); CopyBuffer(maHandleNode6,0,0,10080,maValNode6);
    
   CopyBuffer(adxHandleNode1,0,0,10080,adxValNode1);  CopyBuffer(adxHandleNode2,0,0,10080,adxValNode2);  CopyBuffer(adxHandleNode3,0,0,10080,adxValNode3);
   CopyBuffer(adxHandleNode4,0,0,10080,adxValNode4);  CopyBuffer(adxHandleNode5,0,0,10080,adxValNode5);  CopyBuffer(adxHandleNode6,0,0,10080,adxValNode6);
   
   CopyBuffer(adxHandleNode1,1,0,10080,plsDINode1);   CopyBuffer(adxHandleNode2,1,0,10080,plsDINode2);   CopyBuffer(adxHandleNode3,1,0,10080,plsDINode3);
   CopyBuffer(adxHandleNode4,1,0,10080,plsDINode4);   CopyBuffer(adxHandleNode5,1,0,10080,plsDINode5);   CopyBuffer(adxHandleNode6,1,0,10080,plsDINode6);
   
   CopyBuffer(adxHandleNode1,2,0,10080,minDINode1);   CopyBuffer(adxHandleNode2,2,0,10080,minDINode2);   CopyBuffer(adxHandleNode3,2,0,10080,minDINode3);
   CopyBuffer(adxHandleNode4,2,0,10080,minDINode4);   CopyBuffer(adxHandleNode5,2,0,10080,minDINode5);   CopyBuffer(adxHandleNode6,2,0,10080,minDINode6);
   
   CopyBuffer(macdHandleNode1,0,0,10080,mainLineNode1);  CopyBuffer(macdHandleNode2,0,0,10080,mainLineNode2);  CopyBuffer(macdHandleNode3,0,0,10080,mainLineNode3);
   CopyBuffer(macdHandleNode4,0,0,10080,mainLineNode4);  CopyBuffer(macdHandleNode5,0,0,10080,mainLineNode5);  CopyBuffer(macdHandleNode6,0,0,10080,mainLineNode6);
   
   CopyBuffer(macdHandleNode1,1,0,10080,signalLineNode1);   CopyBuffer(macdHandleNode2,1,0,10080,signalLineNode2);   CopyBuffer(macdHandleNode3,1,0,10080,signalLineNode3);
   CopyBuffer(macdHandleNode4,1,0,10080,signalLineNode4);   CopyBuffer(macdHandleNode5,1,0,10080,signalLineNode5);   CopyBuffer(macdHandleNode6,1,0,10080,signalLineNode6);
   
   CopyBuffer(rsiHandleNode1,0,0,10080,rsiValNode1);  CopyBuffer(rsiHandleNode2,0,0,10080,rsiValNode2);  CopyBuffer(rsiHandleNode3,0,0,10080,rsiValNode3);
   CopyBuffer(rsiHandleNode4,0,0,10080,rsiValNode4);  CopyBuffer(rsiHandleNode5,0,0,10080,rsiValNode5);  CopyBuffer(rsiHandleNode6,0,0,10080,rsiValNode6);
}

void GAZiom::evaluation()
{
   //Inicjalizacja zmiennych wykorzystywanych do symulacji procesu tradingu: budżet początkowy, wolumen (wielkość inwestycji, stop loss, take profit, zmiana ceny,
   //moment zawarcia transakcji, zmienne binarne wskazujące czy jest otwarta już pozycja, czy spełniona jest reguła kupna, czy spełniona jest reguła sprzedaży)
   double budget  = 100000;
   double volume = 1000;
   double stopLoss = 15; //%
   double takeProfit = 15; //%
   double priceChange; //%
   int whenPositionOpen;
   bool isPositionOpen = false;
   bool ifBuy = false;
   bool ifSell  = false;
   //Ocena każdego osobnika
   for (int whichInd = 0; whichInd < popSize; whichInd++)
   {
      fillIndicatorsArrays(whichInd);
      //Iteracja przez tablice z kursem pary walutowej
      for (int i = 10077; i >= 0; i--)
      {
         //Jeśli nie ma otwartej pozycji to sprawdź czy można kupić lub sprzedać walutę
         if (isPositionOpen == false)
         {
            ifBuy = checkBuyRule(whichInd,i);
            if (ifBuy == true)
            {
               //Jeśli można kupić to otwórz pozycję
               isPositionOpen = true;
               whenPositionOpen = i;
            }
            else
            {
               ifSell = checkSellRule(whichInd,i);
               if (ifSell == true)
               {
                  //Jeśli można sprzedać to otwórz pozycję
                  isPositionOpen = true;
                  whenPositionOpen = i;
               }
            }
         }
         //Jeśli otwarto pozycję kupna to obliczaj jej zysk lub stratę
         if ((isPositionOpen == true) && (ifBuy == true))
         {
            //Obsłuż kupno do uzyskania stopLoss lub takeProfit
            //Oblicz zysk procentowy w danym momencie
            priceChange = ((price[i].close*volume - price[whenPositionOpen].close*volume)/(price[whenPositionOpen].close*volume))*100;
            //Jeśli zysk jest większy niż takeProfit to zamknij pozycję i dodaj do budżetu zysk
            if (priceChange >= takeProfit)
            {
               isPositionOpen = false;
               budget = budget + priceChange * volume;
            }
            //Jeśli transakcja przyniosła stratę większą niż stopLoss to zamknij pozycję i odejmij od budżetu stratę
            else if (priceChange <= stopLoss*-1)
            {
               isPositionOpen = false;
               budget = budget - priceChange * volume;
            }
         }
         //Jeśli otwarto pozycję sprzedaży to obliczaj jej zysk lub stratę
         if ((isPositionOpen == true) && (ifSell == true))
         {
            //Obsłuż sprzedaż do uzyskania stopLoss lub takeProfit
            //Oblicz zysk procentowy w danym momencie
            priceChange = ((price[i].close*volume - price[whenPositionOpen].close*volume)/(price[whenPositionOpen].close*volume))*100;
            //Jeśli zysk jest większy niż takeProfit to zamknij pozycję i dodaj do budżetu zysk
            if (priceChange <= takeProfit*-1)
            {
               isPositionOpen = false;
               budget = budget + priceChange * volume;
            }
            //Jeśli transakcja przyniosła stratę większą niż stopLoss to zamknij pozycję i odejmij od budżetu stratę
            else if (priceChange >= stopLoss)
            {
               isPositionOpen = false;
               budget = budget - priceChange * volume;
            }
         }
      }
      //Po zakończeniu oceniania przypisz każdemu osobnikowi wartość jego funkcji przystosowania (budżet po zakończeniu handlu)
      population[whichInd].fitness = budget;
   }
}

void GAZiom::keepTheBest()
{
	population[popSize]=population[0];
	for (int i = 0; i < popSize; i++)
	{
		if (population[popSize].fitness < population[i].fitness)
			population[popSize] = population[i];
	}
}

void GAZiom::selection()
{
   float fitnessSum = population[0].fitness;
	float p;
	for (int i = 1; i < popSize; i++)
	{
		fitnessSum += population[i].fitness;
	}
	for (int i = 0; i < popSize; i++)
	{
		population[i].rfitness= population[i].fitness/fitnessSum;
	}
	population[0].cfitness = population[0].rfitness;
	for (int i = 1; i < popSize; i++)
	{
		population[i].cfitness = population[i].rfitness + population[i-1].rfitness;
	}
	for (int i = 0; i < popSize; i++)
	{
		p=randomValue(0,100)/100;
		if (p < population[0].cfitness)
			newPopulation[i] = population[0];
		else
			for (int j = 0; j < popSize-1; j++)
			{
				if (p>=population[j].cfitness&&p<population[j+1].cfitness)
				{
					newPopulation[i] = population[j+1];
				}
			}
	}
    for ( int i=0; i<popSize; i++)
                population[i] = newPopulation[i];
}

void GAZiom::cross(int firstInd, int secondInd)
{
   int point = 0;
   //Tymczasowe tablice przechowujące strukturę krzyżowanego osobnika
   //Węzły drzewa (AND, OR, wskaźniki: MA,RSI,ADX,MACD)
   int tempTree[ArraySize(population[firstInd].tree)];
   //Parametry wskaźnika MA
   int tempMAarray[ArraySize(population[firstInd].MAarray)]; //MaPeriod
   //Parametry wskaźnika RSI
   int tempRSIarray[ArraySize(population[firstInd].RSIarray)]; //rsiPeriod, minRSI, maxRSI
   //Parametry wskaźnika ADX
   int tempADXarray[ArraySize(population[firstInd].ADXarray)]; //adxPeriod, minADX
   //Parametry wskaźnika MAXD
   int tempMACDarray[ArraySize(population[firstInd].MACDarray)]; //fastMA, slowMA, signalPeriod
   
   //Losowanie, od którego węzła drzewa decyzyjnego zajdzie krzyżowanie
   point = randomValue(1,6);
   
   //Kopiowanie pierwszego osobnika
   for (int i = 0; i < ArraySize(population[firstInd].tree); i++)
   {
      tempTree[i] = population[firstInd].tree[i];
   }
   for (int i = 0; i < ArraySize(population[firstInd].MAarray); i++)
   {
      tempMAarray[i] = population[firstInd].MAarray[i];
   }
   for (int i = 0; i < ArraySize(population[firstInd].RSIarray); i++)
   {
      tempRSIarray[i] = population[firstInd].RSIarray[i];
   }
   
   for (int i = 0; i < ArraySize(population[firstInd].ADXarray); i++)
   {
      tempADXarray[i] = population[firstInd].ADXarray[i];
   }
   for (int i = 0; i < ArraySize(population[firstInd].MACDarray); i++)
   {
      tempMACDarray[i] = population[firstInd].MACDarray[i];
   }
   
   //Wymiana elementów drzewa decyzyjnego w zależności od wylosowanego węzła
   switch (point)
   {
      case 1:
         population[firstInd].tree[0] = population[secondInd].tree[0];
         population[secondInd].tree[0] = tempTree[0];
      break;
      case 2:
         for (int i = 0; i < 2; i++)
         {
            population[firstInd].tree[i] = population[secondInd].tree[i];
            population[secondInd].tree[i] = tempTree[i];
         }
         population[firstInd].MAarray[0] = population[secondInd].MAarray[0];
         population[secondInd].MAarray[0] = tempMAarray[0];
         for (int i = 0; i < 3; i++)
         {
            population[firstInd].RSIarray[i] = population[secondInd].RSIarray[i];
            population[firstInd].MACDarray[i] = population[secondInd].MACDarray[i];
            population[secondInd].RSIarray[i] = tempRSIarray[i];
            population[secondInd].MACDarray[i] = tempMACDarray[i];
         }
         for (int i = 0; i < 2; i++)
         {
            population[firstInd].ADXarray[i] = population[secondInd].ADXarray[i];
            population[secondInd].ADXarray[i] = tempADXarray[i];
         }
      break;
      case 3:
         for (int i = 0; i < 3; i++)
         {
            population[firstInd].tree[i] = population[secondInd].tree[i];
            population[secondInd].tree[i] = tempTree[i];
         }
         for (int i = 0; i < 2; i++)
         {
            population[firstInd].MAarray[i] = population[secondInd].MAarray[i];
            population[secondInd].MAarray[i] = tempMAarray[i];
         }
         for (int i = 0; i < 6; i++)
         {
            population[firstInd].RSIarray[i] = population[secondInd].RSIarray[i];
            population[firstInd].MACDarray[i] = population[secondInd].MACDarray[i];
            population[secondInd].RSIarray[i] = tempRSIarray[i];
            population[secondInd].MACDarray[i] = tempMACDarray[i];
         }
         for (int i = 0; i < 4; i++)
         {
            population[firstInd].ADXarray[i] = population[secondInd].ADXarray[i];
            population[secondInd].ADXarray[i] = tempADXarray[i];
         }
      break;
      case 4:
         for (int i = 0; i < 4; i++)
         {
            population[firstInd].tree[i] = population[secondInd].tree[i];
            population[secondInd].tree[i] = tempTree[i];
         }
         for (int i = 0; i < 3; i++)
         {
            population[firstInd].MAarray[i] = population[secondInd].MAarray[i];
            population[secondInd].MAarray[i] = tempMAarray[i];
         }
         for (int i = 0; i < 9; i++)
         {
            population[firstInd].RSIarray[i] = population[secondInd].RSIarray[i];
            population[firstInd].MACDarray[i] = population[secondInd].MACDarray[i];
            population[secondInd].RSIarray[i] = tempRSIarray[i];
            population[secondInd].MACDarray[i] = tempMACDarray[i];
         }
         for (int i = 0; i < 6; i++)
         {
            population[firstInd].ADXarray[i] = population[secondInd].ADXarray[i];
            population[secondInd].ADXarray[i] = tempADXarray[i];
         }
      break;
      case 5:
         for (int i = 0; i < 5; i++)
         {
            population[firstInd].tree[i] = population[secondInd].tree[i];
            population[secondInd].tree[i] = tempTree[i];
         }
         for (int i = 0; i < 4; i++)
         {
            population[firstInd].MAarray[i] = population[secondInd].MAarray[i];
            population[secondInd].MAarray[i] = tempMAarray[i];
         }
         for (int i = 0; i < 12; i++)
         {
            population[firstInd].RSIarray[i] = population[secondInd].RSIarray[i];
            population[firstInd].MACDarray[i] = population[secondInd].MACDarray[i];
            population[secondInd].RSIarray[i] = tempRSIarray[i];
            population[secondInd].MACDarray[i] = tempMACDarray[i];
         }
         for (int i = 0; i < 8; i++)
         {
            population[firstInd].ADXarray[i] = population[secondInd].ADXarray[i];
            population[secondInd].ADXarray[i] = tempADXarray[i];
         }
      break;
      case 6:
         for (int i = 0; i < 6; i++)
         {
            population[firstInd].tree[i] = population[secondInd].tree[i];
            population[secondInd].tree[i] = tempTree[i];
         }
         for (int i = 0; i < 5; i++)
         {
            population[firstInd].MAarray[i] = population[secondInd].MAarray[i];
            population[secondInd].MAarray[i] = tempMAarray[i];
         }
         for (int i = 0; i < 15; i++)
         {
            population[firstInd].RSIarray[i] = population[secondInd].RSIarray[i];
            population[firstInd].MACDarray[i] = population[secondInd].MACDarray[i];
            population[secondInd].RSIarray[i] = tempRSIarray[i];
            population[secondInd].MACDarray[i] = tempMACDarray[i];
         }
         for (int i = 0; i < 10; i++)
         {
            population[firstInd].ADXarray[i] = population[secondInd].ADXarray[i];
            population[secondInd].ADXarray[i] = tempADXarray[i];
         }
      break;
   }
}
   
void GAZiom::crossover()
{
   float p = 0;
   int one = 0;
   int two = 0;
   
   for (int i = 0; i < popSize; i++)
   {
   	if (randomValue(0, 100)/100<pCross)
      {
         one = i;
         p = randomValue(0, 100)/100;
   		if (p < population[0].cfitness) two = 0;
   		else
         for (int j = 0; j < popSize-1; j++)
   		{
   			if (p>=population[j].cfitness && p<population[j+1].cfitness)
   			{
   				two=j+1;
   			}
   		}
         cross(one, two);
      }
   }
}

void GAZiom::mutation()
{
	/*for (int i = 0; i < PopSize; i++)
		for (int j = 0; j < nVar; j++)
			if (randomValue(0, 1) < pMut)
				population[i].x[j] = randomValue(lower[j], upper[j]);*/
}

void GAZiom::elitism()
{
	float bestVal=population[0].fitness;
	float worstVal= population[0].fitness;
	int best = 0;
	int worst = 0;
	for (int i = 0; i < popSize; i++)
    {
		if (population[i].fitness > bestVal)
		{
			bestVal = population[i].fitness;
			best = i;
		}
		if (population[i].fitness < worstVal)
		{
			worstVal = population[i].fitness;
			worst = i;
		}
	}
	if (population[popSize].fitness < population[best].fitness)
		population[popSize] = population[best];
	else
		population[worst] = population[popSize];
}