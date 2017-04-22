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
   //Okres liczenia wskażnika MA
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
   int signalPeriod;
   
   //Definicja osobnika
   struct individual
   {
      //Tablice przechowujące informacje o osobniku
      //Węzły drzewa (AND, OR, wskaźniki: MA,RSI,ADX,MACD)
      int tree[7];
      //Parametry wskaźnika MA
      int MAarray[6];
      //Parametry wskaźnika RSI
      int RSIarray[18];
      //Parametry wskaźnika ADX
      int ADXarray[12];
      //Parametry wskaźnika MAXD
      int MACDarray[18];
      //Wartość funkcji przystosowania
      double fitness;
      //Zmienne pomocnicze wykorzystywane w selekcji
      double cfitness;
      double rfitness;   
   };
   //Uchwyty do wskaźników
   int maHandle;
   int adxHandle;
   int macdHandle;
   int rsiHandle;
   //Definicja tablicy przechowującej populację
   individual population[];
   //Definicja tablicy przechowującej nową populację
   individual newPopulation[];
   //Definicja tablicy przechowującej wartości wskaźnika MA
   double maVal[];
   //Definicja tablicy przechowującej wartości wskaźnika ADX
   double adxVal[];
   //Definicja tablicy przechowującej wartości linii plus DI wskaźnika ADX
   double plsDI[];
   //Definicja tablicy przechowującej wartości linii minus DI wskaźnika ADX
   double minDI[];
   //Definicja tablicy przechowującej wartości linii głównej wskaźnika MACD
   double mainLine[];
   //Definicja tablicy przechowującej wartości linii sygnałowej wskaźnika MACD
   double signalLine[];
   //Definicja tablicy przechowującej wartości wskaźnika RSI
   double rsiVal[];
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
      //Metoda nadzorująca otwartą pozycję, metoda zwraca numer szufladki z notowaniem pary walutowej na którym pozycja została zamknięta
      int supervisePosition();
      //Metoda dokonująca oceny każdego osobnika populacji
      void evaluation();
      //Metoda zachowująca najlepszego osobika populacji
      //void keepTheBest();
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
      //symbol = //wziąć wartości z obiektu expertAdvisor
      //period = 
      //appliedPrice =
      //Utworzenie tablicy przechowującej populację
      ArrayResize(population,popSize+1);
      //Utworzenie tablicy przechowującej nową populację
      ArrayResize(newPopulation,popSize+1);
      
      //Utworzenie uchwytów do wskaźników
      //Uchwyt do MA
      maHandle = iMA(symbol,timeframe,maPeriod,0,MODE_SMA,appliedPrice);
      //Uchwyt do ADX
      adxHandle = iADX(symbol,timeframe,adxPeriod);
      //Uchwyt do MACD
      macdHandle = iMACD(symbol,timeframe,fastMA,slowMA,signalPeriod,appliedPrice);
      //Uchwyt do RSI
      rsiHandle = iRSI(symbol,timeframe,rsiPeriod,appliedPrice);
      
      //Wypełnienie tablic z wartościami wskaźników
      //Wybrano liczbę wartości do pobrania jako 10080 bo przy docelowym okresie zbierania danych 1 min będie to 2 tygodnie
      //Zgodnie z założeniem Expert grać będzie krótkoterminowo więc dane z dwóch tygodni powinny wystarczyć
      CopyBuffer(maHandle,0,0,10080,maVal);
      CopyBuffer(adxHandle,0,0,10080,adxVal);
      CopyBuffer(adxHandle,1,0,10080,plsDI);
      CopyBuffer(adxHandle,2,0,10080,minDI);
      CopyBuffer(macdHandle,0,0,10080,mainLine);
      CopyBuffer(macdHandle,1,0,10080,signalLine);
      CopyBuffer(rsiHandle,0,0,10080,rsiVal);
      
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
		   population[i].MAarray[j] = randomValue(5,15);
		}
		//Losowanie minRSI
		for (int j = 1; j < 17; j+=3)
		{
		   population[i].MAarray[j] = randomValue(20,30);
		}
		//Losowanie maxRSI
		for (int j = 2; j < 18; j+=3)
		{
		   population[i].MAarray[j] = randomValue(70,80);
		}
		
		//Losowanie wartości parametrów wskaźnika ADX dla węzłów 1 - 6
		//Losowanie adxPeriod
		for (int j = 0; j < 11; j+=2)
		{
		   population[i].MAarray[j] = randomValue(5,15);
		}
		//Losowanie ADXmin
		for (int j = 1; j < 12; j+=2)
		{
		   population[i].MAarray[j] = randomValue(20,30);
		}
		
		//Losowanie wartości parametrów wskaźnika MACD dla węzłów 1 - 6
		//Losowanie fastMA
		for (int j = 0; j < 16; j+=3)
		{
		   population[i].MAarray[j] = randomValue(10,16);
		}
		//Losowanie slowMA
		for (int j = 1; j < 17; j+=3)
		{
		   population[i].MAarray[j] = randomValue(23,29);
		}
		//Losowanie singalPerid
		for (int j = 2; j < 18; j+=3)
		{
		   population[i].MAarray[j] = randomValue(7,10);
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
      case 1: lvl2BuyRule1 = (((maVal[i-2] > maVal[i-1]) && (maVal[i-1] > maVal[i])) && (price[i].close > maVal[i])); break;
      case 2: lvl2BuyRule1 = ((rsiVal[i] > minRSI) && (rsiVal[i-1] < minRSI)); break;
      case 3: lvl2BuyRule1 = ((adxVal[i] > minADX) && (plsDI[i] > minDI[i])); break;
      case 4: lvl2BuyRule1 = ((mainLine[i] > signalLine[i]) && (mainLine[i-1] < mainLine[i-1])); break;
   }
   //Reguła druga drugiego poziomu - generowana w zależności od wartości czwartej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[4])
   {
      case 1: lvl2BuyRule2 = (((maVal[i-2] > maVal[i-1]) && (maVal[i-1] > maVal[i])) && (price[i].close > maVal[i])); break;
      case 2: lvl2BuyRule2 = ((rsiVal[i] > minRSI) && (rsiVal[i-1] < minRSI)); break;
      case 3: lvl2BuyRule2 = ((adxVal[i] > minADX) && (plsDI[i] > minDI[i])); break;
      case 4: lvl2BuyRule2 = ((mainLine[i] > signalLine[i]) && (mainLine[i-1] < mainLine[i-1])); break;
   }
   //Reguła trzecia drugiego poziomu - generowana w zależności od wartości piątej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[5])
   {
      case 1: lvl2BuyRule3 = (((maVal[i-2] > maVal[i-1]) && (maVal[i-1] > maVal[i])) && (price[i].close > maVal[i])); break;
      case 2: lvl2BuyRule3 = ((rsiVal[i] > minRSI) && (rsiVal[i-1] < minRSI)); break;
      case 3: lvl2BuyRule3 = ((adxVal[i] > minADX) && (plsDI[i] > minDI[i])); break;
      case 4: lvl2BuyRule3 = ((mainLine[i] > signalLine[i]) && (mainLine[i-1] < mainLine[i-1])); break;
   }
   //Reguła czwarta drugiego poziomu - generowana w zależności od wartości szóstej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[6])
   {
      case 1: lvl2BuyRule4 = (((maVal[i-2] > maVal[i-1]) && (maVal[i-1] > maVal[i])) && (price[i].close > maVal[i])); break;
      case 2: lvl2BuyRule4 = ((rsiVal[i] > minRSI) && (rsiVal[i-1] < minRSI)); break;
      case 3: lvl2BuyRule4 = ((adxVal[i] > minADX) && (plsDI[i] > minDI[i])); break;
      case 4: lvl2BuyRule4 = ((mainLine[i] > signalLine[i]) && (mainLine[i-1] < mainLine[i-1])); break;
   }
   //Reguły pierwszego poziomu
   //Reguła pierwsza drugiego poziomu - generowana w zależności od wartości pierwszej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[1])
   {
      case 1: lvl1BuyRule1 = lvl2BuyRule1 || lvl2BuyRule2; break;
      case 2: lvl1BuyRule1 = lvl2BuyRule1 || lvl2BuyRule2; break;
      case 3: lvl1BuyRule1 = lvl2BuyRule1 && lvl2BuyRule2; break;
      case 4: lvl1BuyRule1 = lvl2BuyRule1 && lvl2BuyRule2; break;
      case 5: lvl1BuyRule1 = (((maVal[i-2] > maVal[i-1]) && (maVal[i-1] > maVal[i])) && (price[i].close > maVal[i])); break;
      case 6: lvl1BuyRule1 = ((rsiVal[i] > minRSI) && (rsiVal[i-1] < minRSI)); break;
      case 7: lvl1BuyRule1 = ((adxVal[i] > minADX) && (plsDI[i] > minDI[i])); break;
      case 8: lvl1BuyRule1 = ((mainLine[i] > signalLine[i]) && (mainLine[i-1] < mainLine[i-1])); break;
   }
   //Reguła druga drugiego poziomu - generowana w zależności od wartości drgiej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[2])
   {
      case 1: lvl1BuyRule2 = lvl2BuyRule1 || lvl2BuyRule2; break;
      case 2: lvl1BuyRule2 = lvl2BuyRule1 || lvl2BuyRule2; break;
      case 3: lvl1BuyRule2 = lvl2BuyRule1 && lvl2BuyRule2; break;
      case 4: lvl1BuyRule2 = lvl2BuyRule1 && lvl2BuyRule2; break;
      case 5: lvl1BuyRule2 = (((maVal[i-2] > maVal[i-1]) && (maVal[i-1] > maVal[i])) && (price[i].close > maVal[i])); break;
      case 6: lvl1BuyRule2 = ((rsiVal[i] > minRSI) && (rsiVal[i-1] < minRSI)); break;
      case 7: lvl1BuyRule2 = ((adxVal[i] > minADX) && (plsDI[i] > minDI[i])); break;
      case 8: lvl1BuyRule2 = ((mainLine[i] > signalLine[i]) && (mainLine[i-1] < mainLine[i-1])); break;
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
   switch (population[whichIndividual].tree[3])
   {
      case 1: lvl2SellRule1 = (((maVal[i-2] < maVal[i-1]) && (maVal[i-1] < maVal[i])) && (price[i].close < maVal[i])); break;
      case 2: lvl2SellRule1 = ((rsiVal[i] < maxRSI) && (rsiVal[i-1] > maxRSI)); break;
      case 3: lvl2SellRule1 = ((adxVal[i] > minADX) && (plsDI[i] < minDI[i])); break;
      case 4: lvl2SellRule1 = ((mainLine[i] < signalLine[i]) && (mainLine[i-1] > mainLine[i-1])); break;
   }
   //Reguła druga drugiego poziomu - generowana w zależności od wartości czwartej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[4])
   {
      case 1: lvl2SellRule2 = (((maVal[i-2] < maVal[i-1]) && (maVal[i-1] < maVal[i])) && (price[i].close < maVal[i])); break;
      case 2: lvl2SellRule2 = ((rsiVal[i] < maxRSI) && (rsiVal[i-1] > maxRSI)); break;
      case 3: lvl2SellRule2 = ((adxVal[i] > minADX) && (plsDI[i] < minDI[i])); break;
      case 4: lvl2SellRule2 = ((mainLine[i] < signalLine[i]) && (mainLine[i-1] > mainLine[i-1])); break;
   }
   //Reguła trzecia drugiego poziomu - generowana w zależności od wartości piątej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[5])
   {
      case 1: lvl2SellRule3 = (((maVal[i-2] < maVal[i-1]) && (maVal[i-1] < maVal[i])) && (price[i].close < maVal[i])); break;
      case 2: lvl2SellRule3 = ((rsiVal[i] < maxRSI) && (rsiVal[i-1] > maxRSI)); break;
      case 3: lvl2SellRule3 = ((adxVal[i] > minADX) && (plsDI[i] < minDI[i])); break;
      case 4: lvl2SellRule3 = ((mainLine[i] < signalLine[i]) && (mainLine[i-1] > mainLine[i-1])); break;
   }
   //Reguła czwarta drugiego poziomu - generowana w zależności od wartości szóstej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[6])
   {
      case 1: lvl2SellRule4 = (((maVal[i-2] < maVal[i-1]) && (maVal[i-1] < maVal[i])) && (price[i].close < maVal[i])); break;
      case 2: lvl2SellRule4 = ((rsiVal[i] < maxRSI) && (rsiVal[i-1] > maxRSI)); break;
      case 3: lvl2SellRule4 = ((adxVal[i] > minADX) && (plsDI[i] < minDI[i])); break;
      case 4: lvl2SellRule4 = ((mainLine[i] < signalLine[i]) && (mainLine[i-1] > mainLine[i-1])); break;
   }
   //Reguły pierwszego poziomu
   //Reguła pierwsza drugiego poziomu - generowana w zależności od wartości pierwszej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[1])
   {
      case 1: lvl1SellRule1 = lvl2SellRule1 || lvl2SellRule2; break;
      case 2: lvl1SellRule1 = lvl2SellRule1 || lvl2SellRule2; break;
      case 3: lvl1SellRule1 = lvl2SellRule1 && lvl2SellRule2; break;
      case 4: lvl1SellRule1 = lvl2SellRule1 && lvl2SellRule2; break;
      case 5: lvl1SellRule1 = (((maVal[i-2] < maVal[i-1]) && (maVal[i-1] < maVal[i])) && (price[i].close < maVal[i])); break;
      case 6: lvl1SellRule1 = ((rsiVal[i] < maxRSI) && (rsiVal[i-1] > maxRSI)); break;
      case 7: lvl1SellRule1 = ((adxVal[i] > minADX) && (plsDI[i] < minDI[i])); break;
      case 8: lvl1SellRule1 = ((mainLine[i] < signalLine[i]) && (mainLine[i-1] > mainLine[i-1])); break;
   }
   //Reguła druga drugiego poziomu - generowana w zależności od wartości drgiej "szufladki" tablicy z drzewem decyzyjnym
   switch (population[whichIndividual].tree[2])
   {
      case 1: lvl1SellRule2 = lvl2SellRule1 || lvl2SellRule2; break;
      case 2: lvl1SellRule2 = lvl2SellRule1 || lvl2SellRule2; break;
      case 3: lvl1SellRule2 = lvl2SellRule1 && lvl2SellRule2; break;
      case 4: lvl1SellRule2 = lvl2SellRule1 && lvl2SellRule2; break;
      case 5: lvl1SellRule2 = (((maVal[i-2] < maVal[i-1]) && (maVal[i-1] < maVal[i])) && (price[i].close < maVal[i])); break;
      case 6: lvl1SellRule2 = ((rsiVal[i] < maxRSI) && (rsiVal[i-1] > maxRSI)); break;
      case 7: lvl1SellRule2 = ((adxVal[i] > minADX) && (plsDI[i] < minDI[i])); break;
      case 8: lvl1SellRule2 = ((mainLine[i] < signalLine[i]) && (mainLine[i-1] > mainLine[i-1])); break;
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
      //Iteracja przez tablice z kursem pary walutowej
      for (int i = 10078; i >= 0; i--)
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

/*void GAZiom::keepTheBest()
{
	population[PopSize]=population[0];
	for (int i = 0; i < PopSize; i++)
	{
		if (population[PopSize].fitness < population[i].fitness)
			population[PopSize] = population[i];
	}
}*/

