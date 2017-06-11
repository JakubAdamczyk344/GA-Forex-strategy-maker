//+------------------------------------------------------------------+
//|                                                       CallGA.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <GA.mqh>
input string FileName="bestIndividual.bin";
input string InpDirectoryName="DataEABacktesting";

//Funkcja wywołująca algortym genetyczny żądaną liczbę razy, wybierająca najlepszego osobnika ze wszystkich przebiegów, zapisująca go do pliku i drukująca go
void CallGA(int &tree[], int &MAarray[], int &ADXarray[], int &RSIarray[], int &MACDarray[], double &bestFitness, int howMany,
            int popSize,int nGen, float pCross, float pMut, int history, bool ifDate, datetime startDate, datetime stopDate, double stopLoss, double takeProfit, double volume)
{
   //Tablica przechowująca osobniki
   individual indArray[];
   ArrayResize(indArray,howMany);
   //Wywołanie algorytmy genetycznego żądaną ilość razy
   for (int i = 0; i < howMany; i++)
   {
      printf("Nowy przebieg algorytmu");
      GA AG(popSize, nGen, pCross, pMut, history, ifDate, startDate, stopDate, stopLoss, takeProfit, volume);
      int generation = 0;
      AG.initialization();
      AG.evaluation();
      AG.keepTheBest();
      while (generation < AG.nGen)
      {
         AG.selection();
         AG.crossover();
   		AG.mutation();
   		AG.evaluation();
   		AG.elitism();
   		generation++;
      }
      //Zapisanie najlepszego osobnika z danego przebiegu do tablicy
      AG.returnBest(indArray[i].tree,indArray[i].MAarray,indArray[i].ADXarray,indArray[i].RSIarray,indArray[i].MACDarray, indArray[i].fitness);
   }
   //Znalezienie najlepszego wyniku spośród wszystkich przebiegów
   float bestVal=indArray[0].fitness;
   int best = 0;
   for (int i = 0; i < howMany; i++)
    {
		if (indArray[i].fitness > bestVal)
		{
			bestVal = indArray[i].fitness;
			best = i;
		}
	}
	//Zapisanie najlepszego osobnika do tablic podanych w argumencie - przyda się do czasów w czasie rzeczywistym
	bestFitness = bestVal;
	ArrayCopy(tree,indArray[best].tree,0,0);
	ArrayCopy(MAarray,indArray[best].MAarray,0,0);
	ArrayCopy(ADXarray,indArray[best].ADXarray,0,0);
	ArrayCopy(RSIarray,indArray[best].RSIarray,0,0);
	ArrayCopy(MACDarray,indArray[best].MACDarray,0,0);
	
	//Zapisanie najlepszego osobnika do pliku
	//Najpierw wyczyścić folder z danymi na temat najlepszego osobnika
	FolderClean(InpDirectoryName);
	//Zapisanie najlepszego osobnika
   string filePath=InpDirectoryName+"//"+FileName;
	int fileHandle=FileOpen(filePath,FILE_READ|FILE_WRITE|FILE_BIN);
	FileWriteStruct(fileHandle,indArray[best]);
	
	//Drukowanie najlpszego osobnika (przyda się przy backtestach)
	printf("Drukowanie najlepszego osobnika wszystkich przebiegów");
	printf("Wielkość tree");
   int rozmiarTree = sizeof(indArray[best].tree);
   printf(rozmiarTree);
   printf("Zawartość tree");
   for (int i = 0; i < 7; i++)
   {
      printf(indArray[best].tree[i]);
   }
   printf("Wielkość MAarray");
   int rozmiarMA = sizeof(indArray[best].MAarray);
   printf(rozmiarMA);
   printf("Zawartość MAarray");
   for (int i = 0; i < 6; i++)
   {
      printf(indArray[best].MAarray[i]);
   }
   printf("Zawartość ADXarray");
   for (int i = 0; i < 12; i++)
   {
      printf(indArray[best].ADXarray[i]);
   }
   printf("Zawartość RSIarray");
   for (int i = 0; i < 18; i++)
   {
      printf(indArray[best].RSIarray[i]);
   }
   printf("Zawartość MACDarray");
   for (int i = 0; i < 18; i++)
   {
      printf(indArray[best].MACDarray[i]);
   }
}

