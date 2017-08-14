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
   CallGA(ind[0].tree, ind[0].MAarray, ind[0].ADXarray, ind[0].RSIarray, ind[0].MACDarray, ind[0].fitness, 50, 50, 50, 0.2,0.02,60000,false,D'2016.08.10 0:00:00',D'2016.10.10 0:00:00',30,100,0.1);
}