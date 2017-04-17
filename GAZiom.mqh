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
   ENUM_TIMEFRAMES period;
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
      int tree[8];
      //Parametry wskaźnika MA
      int MAarray[6];
      //Parametry wskaźnika RSI
      int RSIarray[18];
      //Parametry wskaźnika ADX
      int ADXarray[12];
      //Parametry wskaźnika MAXD
      int MACDarray[18];
      //Wartość funkcji przystosowania
      float fitness;
      //Dodać komentarz
      float cfitness;
      //Dodać komentarz
      float rfitness;   
   };
   //Definicja tablicy przechowującej populację
   individual population[];
   //Definicja tablicy przechowującej nową populację
   individual newPopulation[];
   //Definicja tablicy przechowującej wartości wskaźnika MA
   float maVal[];
   //Definicja tablicy przechowującej wartości wskaźnika ADX
   float adxVal[];
   //Definicja tablicy przechowującej wartości linii plus DI wskaźnika ADX
   float plsDI[];
   //Definicja tablicy przechowującej wartości linii minus DI wskaźnika ADX
   float minDI[];
   //Definicja tablicy przechowującej wartości linii głównej wskaźnika MACD
   float mainLine[];
   //Definicja tablicy przechowującej wartości linii sygnałowej wskaźnika MACD
   float signalLine[];
   //Definicja tablicy przechowującej wartości wskaźnika RSI
   float rsiVal[];
public:
      //Konstruktor
      GAZiom();
      //Destruktor
      ~GAZiom();
      //Metoda zwracająca liczbę pseudolosową z podanego zakresu min - max
      int randomValue(int min, int max);
      //Metoda tworząca populację początkową
      void initialization();
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

void GAZiom::evaluation()
{
   
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

