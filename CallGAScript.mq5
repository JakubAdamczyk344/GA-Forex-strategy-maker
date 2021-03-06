//+------------------------------------------------------------------+
//|                                                 CallGAScript.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

//Skrypt do testowania działania funkcji CallGA i do wywoływania jej na potrzeby backtestów

#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <GA.mqh>
#include <CallGA.mqh>

void OnStart()
{
   printf("Wywołano");
   //Utworzenie osobnika - jest potrzebny by podać funkcji CallGA tablice jako argumenty, przy backtestach tego nie wykorzystam
   //Ale przy testach w czasie rzeczywistych już jak najbardziej, to będzie osobnik którym będę grał
   individual ind[1];
   CallGA(ind[0].tree, ind[0].MAarray, ind[0].ADXarray, ind[0].RSIarray, ind[0].MACDarray, ind[0].fitness, 1, 10, 10, 0.8,0.01,10080,false,D'2017.03.01 8:00:00',D'2017.05.01 8:00:00',0.5,0.5,0.1);
}