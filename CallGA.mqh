//+------------------------------------------------------------------+
//|                                                       CallGA.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <GA.mqh>
input string FileName="bestIndividual.bin";
input string IndDirectoryName="ResultsOpt//BestIndividualEA";

//Do zapisu tablic osobnika do pliku
input string ArraysFileName="arrays.txt";
input string ArraysDirectoryName="ResultsOpt//ArraysEA";

//Do zapisu czasu optymalizacji
input string TimeFileName="optTime.csv";
input string TimeDirectoryName="ResultsOpt//TimeEA";

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
      //Zapisanie najlepszego osobnika z danego przebiegu do tablicy indArray
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
	//Zapisanie najlepszego osobnika do tablic podanych w argumencie - przyda się do testów w czasie rzeczywistym
	bestFitness = bestVal;
	ArrayCopy(tree,indArray[best].tree,0,0);
	ArrayCopy(MAarray,indArray[best].MAarray,0,0);
	ArrayCopy(ADXarray,indArray[best].ADXarray,0,0);
	ArrayCopy(RSIarray,indArray[best].RSIarray,0,0);
	ArrayCopy(MACDarray,indArray[best].MACDarray,0,0);
	
	//Zapisanie najlepszego osobnika do pliku
	//Najpierw wyczyścić folder z danymi na temat najlepszego osobnika
	FolderClean(IndDirectoryName);
	//Zapisanie najlepszego osobnika
   string filePath=IndDirectoryName+"//"+FileName;
	int indFileHandle=FileOpen(filePath,FILE_READ|FILE_WRITE|FILE_BIN);
	FileWriteStruct(indFileHandle,indArray[best]);
	FileClose(indFileHandle);
	
	//Zapisanie do pliku czasu optymalizacji
	datetime optTime = TimeLocal();
	//datetime optTime = D'2017.03.01 8:00:00';
	FolderClean(TimeDirectoryName);
	string timePath=TimeDirectoryName+"//"+TimeFileName;
	int timeFileHandle=FileOpen(timePath,FILE_READ|FILE_WRITE|FILE_CSV);
	FileWrite(timeFileHandle,optTime);
	FileClose(timeFileHandle);
	
	//Drukowanie najlepszego osobnika do pliku, stąd można go szybko skopiować do EA w backtestach
	FolderClean(ArraysDirectoryName);
	string arraysFilePath=ArraysDirectoryName+"//"+ArraysFileName;
	int arraysFileHandle=FileOpen(arraysFilePath,FILE_READ|FILE_WRITE|FILE_TXT);
	
	//Drukowanie tree
	char charTree[7];
	for (int i=0; i<7; i++)
	{
	   charTree[i] = indArray[best].tree[i];
	}
	for (int i=0; i<7; i++)
	{
	   FileWriteString(arraysFileHandle,"Best.population[0].tree[" + i + "] = " + charTree[i] + ";\n");
	}
	
	//Drukowanie MAarray
	char charMA[6];
	for (int i=0; i<6; i++)
	{
	   charMA[i] = indArray[best].MAarray[i];
	}
	for (int i=0; i<6; i++)
	{
	   FileWriteString(arraysFileHandle,"Best.population[0].MAarray[" + i + "] = " + charMA[i] + ";\n");
	}
	
	//Drukowanie ADXarray
	char charADX[12];
	for (int i=0; i<12; i++)
	{
	   charADX[i] = indArray[best].ADXarray[i];
	}
	for (int i=0; i<12; i++)
	{
	   FileWriteString(arraysFileHandle,"Best.population[0].ADXarray[" + i + "] = " + charADX[i] + ";\n");
	}
	
	//Drukowanie RSIarray
	char charRSI[18];
	for (int i=0; i<18; i++)
	{
	   charRSI[i] = indArray[best].RSIarray[i];
	}
	for (int i=0; i<18; i++)
	{
	   FileWriteString(arraysFileHandle,"Best.population[0].RSIarray[" + i + "] = " + charRSI[i] + ";\n");
	}
	
	//Drukowanie MACDarray
	char charMACD[18];
	for (int i=0; i<18; i++)
	{
	   charMACD[i] = indArray[best].MACDarray[i];
	}
	for (int i=0; i<18; i++)
	{
	   FileWriteString(arraysFileHandle,"Best.population[0].MACDarray[" + i + "] = " + charMACD[i] + ";\n");
	}
	
	printf("Wielkość tree");
   int rozmiarTree = sizeof(indArray[best].tree);
   printf(rozmiarTree);
   printf("Zawartość tree");
   for (int i = 0; i < 7; i++)
   {
      printf(indArray[best].tree[i]);
   }
   FileClose(arraysFileHandle);
   
   printf("Fitness najlepszego osobnika: " + indArray[best].fitness);
   
   /*printf("Wielkość MAarray");
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
   }*/
}