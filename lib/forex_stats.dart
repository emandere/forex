import 'dart:math';
import 'dart:collection';
import "package:collection/collection.dart";
double BollingerUpper(List<double> x)
{
  double val = x.last;
  return val + 2* StdDev(x);
}
double BollingerLower(List<double> x)
{
  double val = x.last;
  return val - 2* StdDev(x);
}
double Average(Iterable x)
{
  double sum = x.reduce((t,e)=>t+e);
  double xavg = sum / x.length;
  return xavg;
}
double StdDev(Iterable x)
{
  double sumsquared = x.map((t)=>t*t)
      .reduce((t,e)=>t+e);
  double stdDev = sqrt((sumsquared/x.length) - (Average(x)*Average(x)));
  return stdDev;
}

double Slope(Iterable y)
{
  //See https://en.wikipedia.org/wiki/Simple_linear_regression
  var x = new List<double>.generate(y.length,(int index)=>index.toDouble()+1.0);
  double AverageX = Average(x);
  double AverageY = Average(y);

  double numerator = new IterableZip([x,y])
      .map((t)=>(t[0]-AverageX)*(t[1]-AverageY))
      .reduce((t,e)=>t+e);

  double denominator = x.map((t)=>pow((t-AverageX),2))
      .reduce((t,e)=>t+e);

  return numerator / denominator;
}

double RSI(Iterable y)
{
   var diff = y.map((t)=>t[1]-t[0]);
   var gains = diff.where((t)=>t>0);
   var losses = diff.where((t)=>t<0);
   double RS = 100.0;

   if(losses.length>0)
      RS = (Average(gains)/Average(losses)).abs();

   double RSI = 100 - (100/(1+RS));

   return RSI;
}