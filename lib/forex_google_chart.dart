@JS('google.visualization')
library visualization;

import 'package:js/js.dart';
import'dart:html';

@JS()
class DataTable
{
   external factory DataTable();
   external addColumn(String type,String name);
   external addRows(var data);
}

@JS("CandlestickChart")

class CandlestickChart// extends chartInterface
{
  external factory CandlestickChart(final DivElement elem);
  external draw(DataTable data,var options);
 /* void drawChart()
  {
     draw(chartData,chartOptions);
  }*/
}

@JS()
abstract class chartInterface
{
  DataTable chartData;
  DataTable chartOptions;
  void drawChart();
  //var jsChart;
 /* factory GoogleCharts(String type,Element elem)
  {
    if(type=="CandleStickChart")
    {
      return CandlestickChart(elem);
    }
  }
 */
}


/*
class GoogleDataChart
{
  static chartInterface GetCharts(String type,Element elem)
  {
    if(type=="CandleStickChart")
    {
      return new CandlestickChart(elem);
    }
  }

}*/



