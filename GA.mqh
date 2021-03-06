//+------------------------------------------------------------------+
//|                                                       GA.mqh     |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <GABase.mqh>

class GA : public GABase
{
protected:
   //Prawdopodobieństwo krzyżowania
   float pCross;
   //Prawdopodobieństwo mutacji
   float pMut;
   //Zmienna przechowująca liczbę próbek historycznych (zależy od wybranego trybu pobierania danych historycznych)
   int historySize;
   //Stop loss
   double stopLoss;
   //Take profit
   double takeProfit;
   //Wolumen handlu
   double volume;
   
   //Definicja tablicy przechowującej nową populację
   individual newPopulation[];
   
public:
      //Konstruktor
      GA(int popSize, int nGen, float pCross, float pMut, int history, bool ifDate, datetime startDate, datetime stopDate, double stopLoss, double takeProfit, double volume);
      //Destruktor
      ~GA();
      //Liczba generacji
      int nGen;
      //Metoda zwracająca liczbę pseudolosową z podanego zakresu min - max
      int randomValue(int min, int max);
      //Metoda zwracająca liczbę pseudolosową z dwóch przedziałów
      int randomValueTwo(int firstMin, int firstMax, int secMin, int secMax);
      //Metoda tworząca populację początkową
      void initialization();
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
      //Metoda zwracająca najlepszą strategię (najlepszego osobnika)
      void returnBest(int &tree[], int &MAarray[], int &ADXarray[], int &RSIarray[], int &MACDarray[], double &bestFitness);
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GA::GA(int popSize, int nGen, float pCross, float pMut, int history, bool ifDate, datetime startDate, datetime stopDate, double stopLoss, double takeProfit, double volume)
  {
      //ustalenie parametrów AG
      this.popSize = popSize;
      this.nGen = nGen;
      this.pCross = pCross; //0.1
      this.pMut = pMut; //0.2
      symbol = "EURUSD";
      appliedPrice = PRICE_CLOSE;
      timeframe = PERIOD_M1;
      this.history = history;
      this.ifDate = ifDate;
      this.startDate = startDate;
      this.stopDate = stopDate;
      this.stopLoss = stopLoss/10000;
      this.takeProfit = takeProfit/10000;
      this.volume = volume;
      //Utworzenie tablicy przechowującej populację
      ArrayResize(population,popSize+1);
      //Utworzenie tablicy przechowującej nową populację
      ArrayResize(newPopulation,popSize+1);
      //Pobranie informacji na temat cen z danego okresu (wykorzystywane do analizy wskażnika MA i do oceny osobników)
      switch(ifDate)
      {
         case false: CopyRates(symbol,timeframe,0,history,price); historySize = history; printf("Zakres historii: %d",historySize); break;
         case true: CopyRates(symbol,timeframe,startDate, stopDate, price); historySize = ArraySize(price); printf("Zakres historii: %d",historySize); break;
      }
  }

GA::~GA()
  {
  }

int GA::randomValue(int min, int max)
{
	double random = MathRand()%10;
	//printf(MathRound((random/9*(max - min))+min));
	return MathRound((random/9*(max - min))+min);
}

int GA::randomValueTwo(int firstMin,int firstMax,int secMin,int secMax)
{
   int first = randomValue(firstMin, firstMax);
   int second = randomValue(secMin, secMax);
   int range = (firstMax - firstMin) + (secMax - secMin) +2;
   if (randomValue(1,range) <= (firstMax - firstMin + 1))
   {
      return first;
   }
   else return second;
}

void GA::initialization(void)
{
   //Iteracja po każdym osobniku populacji
   for (int i = 0; i < popSize; i++)
	{
	   //printf("Losowanie osobnika %d",i);
	   //Tworzenie drzewa osobnika
	   population[i].tree[0] = randomValue(1,2);
		population[i].tree[1] = randomValue(1,8);
		population[i].tree[2] = randomValue(1,8);
		population[i].tree[3] = randomValue(1,4);
		population[i].tree[4] = randomValue(1,4);
		population[i].tree[5] = randomValue(1,4);
		population[i].tree[6] = randomValue(1,4);
		
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
		/*printf("Inicjalizacja osobnika %d",i);
		printf(population[i].tree[0]);
   	printf(population[i].tree[1]);
   	printf(population[i].tree[2]);
   	printf(population[i].tree[3]);
   	printf(population[i].tree[4]);
   	printf(population[i].tree[5]);
   	printf(population[i].tree[6]);*/
   }
}

void GA::evaluation()
{
   //Inicjalizacja zmiennych wykorzystywanych do symulacji procesu tradingu: budżet początkowy, wolumen (wielkość inwestycji, stop loss, take profit, zmiana ceny,
   //moment zawarcia transakcji, zmienne binarne wskazujące czy jest otwarta już pozycja, czy spełniona jest reguła kupna, czy spełniona jest reguła sprzedaży)

   //Ocena każdego osobnika
   for (int whichInd = 0; whichInd < popSize; whichInd++)
   {
      double budget  = 5000;
      double lot = 100000;
      double volume = this.volume;
      double leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
      //double leverage = 100;
      double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);//Obliczać rzeczywiste?
      double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
      double spread = ask - bid;
      double deposit;
      int whenPositionOpen;
      bool isPositionOpen = false;
      bool ifBuy = false;
      bool ifSell  = false;
      double commision = 10*volume;
      fillIndicatorsArrays(whichInd);
      //Iteracja przez tablice z kursem pary walutowej
      for (int i = historySize - 3; i >= 0; i--)
      {
         //Jeśli nie ma otwartej pozycji to sprawdź czy można kupić lub sprzedać walutę
         if (isPositionOpen == false)
         {
            ifBuy = checkBuyRule(whichInd,i);
            //Jeśli spełniona jest reguła kupna
            if (ifBuy == true)
            {
               whenPositionOpen = i;
               ask = price[whenPositionOpen].close + spread/2;
               deposit = (ask*lot*volume)/leverage;
               //Jeśli budżet - depozyt >= 0
               if ((budget - deposit) >=0)
               {
                  //printf("spełniono warunek kupna, osobnik %d, miejsce %d",whichInd,i);
                  //Jeśli można kupić to otwórz pozycję
                  isPositionOpen = true;
                  //whenPositionOpen = i;
               }
            }
            else
            {
               ifSell = checkSellRule(whichInd,i);
               //Jeśli spełniona jest reguła sprzedaży
               if (ifSell == true)
               {
                  whenPositionOpen = i;
                  bid = price[whenPositionOpen].close - spread/2;
                  deposit = (bid*lot*volume)/leverage;
                  //Jeśli budżet - depozyt >= 0
                  if ((budget - deposit) >=0)
                  {
                     //printf("spełniono warunek sprzedaży, osobnik %d, miejsce %d",whichInd,i);
                     //Jeśli można sprzedać to otwórz pozycję
                     isPositionOpen = true;
                     //whenPositionOpen = i;
                  }
               }
            }
         }
         //Jeśli otwarto pozycję kupna to obliczaj jej zysk lub stratę
         if ((isPositionOpen == true) && (ifBuy == true))
         {
            //printf("Obliczanie zysku/straty sprzedaży");
            //Jeśli cena wzrosła o takeProfit to zamknij pozycję i dodaj zysk do budżetu
            if ((price[i].close - price[whenPositionOpen].close) >= takeProfit)
            {
               isPositionOpen = false;
               bid = price[i].close - spread/2;
               budget = budget + (bid - ask)*volume*lot - commision;
            }
            //Jeśli cena spadła o stopLoss to zamknij pozycję i odejmij stratę od budżetu
            else if ((price[whenPositionOpen].close - price[i].close) >= stopLoss)
            {
               isPositionOpen = false;
               bid = price[i].close - spread/2;
               budget = budget - (ask - bid)*volume*lot  - commision;
            }
         }
         //Jeśli otwarto pozycję sprzedaży to obliczaj jej zysk lub stratę
         if ((isPositionOpen == true) && (ifSell == true))
         {
            //printf("Obliczanie zysku/straty sprzedaży");
            //Jeśli cena spadła o takeProfit to zamknij pozycję i dodaj zysk do budżetu
            if ((price[whenPositionOpen].close - price[i].close) >= takeProfit)
            {
               isPositionOpen = false;
               ask = price[i].close + spread/2;
               budget = budget + (bid - ask)*volume*lot  - commision;
            }
            //Jeśli cena wzrosła o stopLoss to zamknij pozycję i odejmij stratę od budżetu
            else if ((price[i].close - price[whenPositionOpen].close) >= stopLoss)
            {
               isPositionOpen = false;
               ask = price[i].close + spread/2;
               budget = budget - (ask - bid)*volume*lot  - commision;
            }
         }
      }
      //Po zakończeniu oceniania przypisz każdemu osobnikowi wartość jego funkcji przystosowania (budżet po zakończeniu handlu)
      //Jeśli budżet mniejszy niż zero to ustawić na 0 (na jego podstawie oblicza się prawdopodobieństwo wylosowania do nowej populacji,
      //nie może być ono mniejsze od zera
      if (budget < 0) budget = 0;
      population[whichInd].fitness = budget;
      printf("Przystosowanie osobnika numer %d: %f",whichInd, budget);
      releaseHandles();
   }
   printf("Przystosowanie osobnika elitarnego %f", population[popSize].fitness);
}

void GA::keepTheBest()
{
	population[popSize]=population[0];
	for (int i = 0; i < popSize; i++)
	{
	   //Iteracja po osobnikach - jeśli osobnik jest lepszy od aktualnie najlepszego to go zastępuje
		if (population[popSize].fitness < population[i].fitness)
			population[popSize] = population[i];
	}
}

void GA::selection()
{
   //Obliczanie sumy funkcji przystosowania wszystkich osobników
   float fitnessSum = population[0].fitness;
	float p;
	for (int i = 1; i < popSize; i++)
	{
		fitnessSum += population[i].fitness;
	}
	for (int i = 0; i < popSize; i++)
	{
	   //Obliczanie prawdopodobieństwa wylosowania do utworzenia nowej populacji
		population[i].rfitness= population[i].fitness/fitnessSum;
	}
	population[0].cfitness = population[0].rfitness;
	for (int i = 1; i < popSize; i++)
	{
	   //Sumowanie rfitness dla osobnika i jego sąsiada w populacji - kumulowanie rfitness
		population[i].cfitness = population[i].rfitness + population[i-1].rfitness;
	}
	for (int i = 0; i < popSize; i++)
	{
	   //Losowanie osobników do nowej populacji na podstawie ich cfitness
		p=randomValue(0,100000000000)/100000000000;
		if (p < population[0].cfitness)
		{
			newPopulation[i] = population[0];
			printf("Osobnik numer %d nowej populacji",i);
		}
		else
			for (int j = 0; j < popSize-1; j++)
			{
				if (p>=population[j].cfitness&&p<population[j+1].cfitness)
				{
					newPopulation[i] = population[j+1];
					printf("Osobnik numer %d nowej populacji",i);
				}
			}
	}
	//Tworzenie nowej populacji na podstawie tymczasowej newPopulation
   for ( int i=0; i<popSize; i++)
                population[i] = newPopulation[i];
}

void GA::cross(int firstInd, int secondInd)
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
   
void GA::crossover()
{
   float p = 0;
   int one = 0;
   int two = 0;
   
   for (int i = 0; i < popSize; i++)
   {
      //Sprawdzanie czy dla i-tego osobnika zajdzie krzyżowanie
   	if (randomValue(0, 100)/100<pCross)
      {
         one = i;
         //Losowanie drugiego osobnika do krzyżowania
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

void GA::mutation()
{
	for (int i = 0; i < popSize; i++)
	{
	   //Sprawdzanie czy dla i-tego osobnika zajdzie mutacja
	   if (randomValue(0, 100)/100 < pMut)
	   {
	      //Losowanie węzła drzewa decyzyjnego, które podlegać będzie mutacji
	      int mutNode = randomValue(0,6);
	      //Mutowanie węzła w zależności od tego, jaką ma wartość i jakie wartości może przyjmować
	      switch (mutNode)
	      {
	         case 0:
	            switch (population[i].tree[0])
	            {
	               case 0: population[i].tree[0] = 1; break;
	               case 1: population[i].tree[0] = 0; break;
	            } break;
	         case 1:
	            switch (population[i].tree[1])
	            {
	               case 1: population[i].tree[1] = randomValue(3,8); break;
	               case 2: population[i].tree[1] = randomValue(3,8); break;
	               case 3: population[i].tree[1] = randomValueTwo(1,2,5,8); break;
	               case 4: population[i].tree[1] = randomValueTwo(1,2,5,8); break;
	               case 5: population[i].tree[1] = randomValueTwo(1,4,6,8); break;
	               case 6: population[i].tree[1] = randomValueTwo(1,5,7,8); break;
	               case 7: population[i].tree[1] = randomValueTwo(1,6,8,8); break;
	               case 8: population[i].tree[1] = randomValue(1,7); break;
	            } break;
	         case 2:
	            switch (population[i].tree[2])
	            {
	               case 1: population[i].tree[2] = randomValue(3,8); break;
	               case 2: population[i].tree[2] = randomValue(3,8); break;
	               case 3: population[i].tree[2] = randomValueTwo(1,2,5,8); break;
	               case 4: population[i].tree[2] = randomValueTwo(1,2,5,8); break;
	               case 5: population[i].tree[2] = randomValueTwo(1,4,6,8); break;
	               case 6: population[i].tree[2] = randomValueTwo(1,5,7,8); break;
	               case 7: population[i].tree[2] = randomValueTwo(1,6,8,8); break;
	               case 8: population[i].tree[2] = randomValue(1,7); break;
	            } break;
	         case 3:
	            switch (population[i].tree[3])
	            {
	               case 1: population[i].tree[3] = randomValue(2,4); break;
	               case 2: population[i].tree[3] = randomValueTwo(1,1,3,4); break;
	               case 3: population[i].tree[3] = randomValueTwo(1,2,4,4); break;
	               case 4: population[i].tree[3] = randomValue(1,3); break;
	            } break;
	         case 4:
	            switch (population[i].tree[4])
	            {
	               case 1: population[i].tree[4] = randomValue(2,4); break;
	               case 2: population[i].tree[4] = randomValueTwo(1,1,3,4); break;
	               case 3: population[i].tree[4] = randomValueTwo(1,2,4,4); break;
	               case 4: population[i].tree[4] = randomValue(1,3); break;
	            } break;
	         case 5:
	            switch (population[i].tree[5])
	            {
	               case 1: population[i].tree[5] = randomValue(2,4); break;
	               case 2: population[i].tree[5] = randomValueTwo(1,1,3,4); break;
	               case 3: population[i].tree[5] = randomValueTwo(1,2,4,4); break;
	               case 4: population[i].tree[5] = randomValue(1,3); break;
	            } break;
	         case 6:
	            switch (population[i].tree[6])
	            {
	               case 1: population[i].tree[6] = randomValue(2,4); break;
	               case 2: population[i].tree[6] = randomValueTwo(1,1,3,4); break;
	               case 3: population[i].tree[6] = randomValueTwo(1,2,4,4); break;
	               case 4: population[i].tree[6] = randomValue(1,3); break;
	            } break;
	      }
	      //Losowanie nowych parametrów wskaźników dla mutowanego węzła
	      switch (mutNode)
	      {
	         case 1: 
	            population[i].MAarray[0] = randomValue(5,15);
	            population[i].RSIarray[0] = randomValue(5,15); population[i].RSIarray[1] = randomValue(20,30); population[i].RSIarray[2] = randomValue(70,80);
	            population[i].ADXarray[0] = randomValue(5,15); population[i].ADXarray[1] = randomValue(20,30);
	            population[i].MACDarray[0] = randomValue(10,16); population[i].MACDarray[1] = randomValue(23,29); population[i].MACDarray[2] = randomValue(7,10);
	         break;
	         case 2: 
	            population[i].MAarray[1] = randomValue(5,15);
	            population[i].RSIarray[3] = randomValue(5,15); population[i].RSIarray[4] = randomValue(20,30); population[i].RSIarray[5] = randomValue(70,80);
	            population[i].ADXarray[2] = randomValue(5,15); population[i].ADXarray[3] = randomValue(20,30);
	            population[i].MACDarray[3] = randomValue(10,16); population[i].MACDarray[4] = randomValue(23,29); population[i].MACDarray[5] = randomValue(7,10);
	         break;
	         case 3: 
	            population[i].MAarray[2] = randomValue(5,15);
	            population[i].RSIarray[6] = randomValue(5,15); population[i].RSIarray[7] = randomValue(20,30); population[i].RSIarray[8] = randomValue(70,80);
	            population[i].ADXarray[4] = randomValue(5,15); population[i].ADXarray[5] = randomValue(20,30);
	            population[i].MACDarray[6] = randomValue(10,16); population[i].MACDarray[7] = randomValue(23,29); population[i].MACDarray[8] = randomValue(7,10);
	         break;
	         case 4: 
	            population[i].MAarray[3] = randomValue(5,15);
	            population[i].RSIarray[9] = randomValue(5,15); population[i].RSIarray[10] = randomValue(20,30); population[i].RSIarray[11] = randomValue(70,80);
	            population[i].ADXarray[6] = randomValue(5,15); population[i].ADXarray[7] = randomValue(20,30);
	            population[i].MACDarray[9] = randomValue(10,16); population[i].MACDarray[10] = randomValue(23,29); population[i].MACDarray[11] = randomValue(7,10);
	         break;
	         case 5: 
	            population[i].MAarray[4] = randomValue(5,15);
	            population[i].RSIarray[12] = randomValue(5,15); population[i].RSIarray[13] = randomValue(20,30); population[i].RSIarray[14] = randomValue(70,80);
	            population[i].ADXarray[8] = randomValue(5,15); population[i].ADXarray[9] = randomValue(20,30);
	            population[i].MACDarray[12] = randomValue(10,16); population[i].MACDarray[13] = randomValue(23,29); population[i].MACDarray[14] = randomValue(7,10);
	         break;
	         case 6: 
	            population[i].MAarray[5] = randomValue(5,15);
	            population[i].RSIarray[15] = randomValue(5,15); population[i].RSIarray[16] = randomValue(20,30); population[i].RSIarray[17] = randomValue(70,80);
	            population[i].ADXarray[10] = randomValue(5,15); population[i].ADXarray[11] = randomValue(20,30);
	            population[i].MACDarray[15] = randomValue(10,16); population[i].MACDarray[16] = randomValue(23,29); population[i].MACDarray[17] = randomValue(7,10);
	         break;
	      }
	   }
	}			
}

void GA::elitism()
{
	float bestVal=population[0].fitness;
	float worstVal= population[0].fitness;
	int best = 0;
	int worst = 0;
	for (int i = 0; i < popSize; i++)
    {
      //Szukanie najlepszego osobnika populacji
		if (population[i].fitness > bestVal)
		{
			bestVal = population[i].fitness;
			best = i;
		}
		//Szukanie najgorszego osobnika populacji
		if (population[i].fitness < worstVal)
		{
			worstVal = population[i].fitness;
			worst = i;
		}
	}
	//Zastąpienie dotychczas elitarnego osobnika kopią aktualnie najlepszego jeśli jest on lepszy od dotychczas elitarnego
	//Najlepszy ciagle też pozostaje na swoim miejscu w populacji by podlegać mutacji i krzyżowaniu
	if (population[popSize].fitness < population[best].fitness)
		population[popSize] = population[best];
	else
	   //Jeśli nie to kopia elitarnego zastępuje najgorszego i będzie podlegać mutacji i krzyżowaniu
		population[worst] = population[popSize];
}

void GA::returnBest(int &tree[], int &MAarray[], int &ADXarray[], int &RSIarray[], int &MACDarray[], double &bestFitness)
{
   //Szukanie najlepszego osobnika populacji
   float bestVal=population[0].fitness;
   int best = 0;
   for (int i = 0; i < popSize; i++)
    {
		if (population[i].fitness > bestVal)
		{
			bestVal = population[i].fitness;
			best = i;
		}
	}
	bestFitness = bestVal;
	ArrayCopy(tree,population[best].tree,0,0);
	ArrayCopy(MAarray,population[best].MAarray,0,0);
	ArrayCopy(ADXarray,population[best].ADXarray,0,0);
	ArrayCopy(RSIarray,population[best].RSIarray,0,0);
	ArrayCopy(MACDarray,population[best].MACDarray,0,0);
}