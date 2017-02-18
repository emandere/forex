import 'dart:math';
import 'forex_stats.dart';

abstract class IndicatorRule
{
  factory IndicatorRule(String ruleName,int dataPoints)
  {
      switch(ruleName)
      {
        case "AboveBollingerBandHigher":
          return new AboveBollingerBandHigher(ruleName,dataPoints);
        case "RandomRule":
          return new RandomRule(ruleName,dataPoints);
        case "BelowBollingerBandLowerWithSlope":
          return new BelowBollingerBandLowerWithSlope(ruleName,dataPoints);
        case "BelowBollingerBandLower":
          return new BelowBollingerBandLower(ruleName,dataPoints);
        case "PositiveSlopeAndGreaterThanAverage":
          return new PositiveSlopeAndGreaterThanAverage(ruleName,dataPoints);
        default:
          throw "Invalid Rule Name";
      }
  }
  String name;
  int dataPoints;
  bool IsMet(Iterable<Map> window,Map currentValue);
}

class PositiveSlopeAndGreaterThanAverage implements IndicatorRule
{

  String name;
  int dataPoints;
  PositiveSlopeAndGreaterThanAverage(this.name,this.dataPoints)
  {

  }
  bool IsMet(Iterable<Map> window,Map currentValue)
  {
    List<double> data = <double>[];
    for(Map day in window)
    {
      data.add(day["close"]);
    }
    if(Slope(data)>0 && Average(data) < currentValue["close"])
      return true;
    else
      return false;
  }
}


class BelowBollingerBandLower implements IndicatorRule
{

  String name;
  int dataPoints;
  BelowBollingerBandLower(this.name,this.dataPoints)
  {

  }
  bool IsMet(Iterable<Map> window,Map currentValue)
  {
    List<double> data = <double>[];
    for(Map day in window)
    {
      data.add(day["close"]);
    }
    if(BollingerLower(data) > currentValue["low"])
      return true;
    else
      return false;
  }
}

class BelowBollingerBandLowerWithSlope implements IndicatorRule
{

  String name;
  int dataPoints;
  BelowBollingerBandLowerWithSlope(this.name,this.dataPoints)
  {

  }
  bool IsMet(Iterable<Map> window,Map currentValue)
  {
    List<double> data = <double>[];
    for(Map day in window)
    {
      data.add(day["close"]);
    }
    if(Slope(data)>0  && BollingerLower(data) > currentValue["low"])
      return true;
    else
      return false;
  }
}

class AboveBollingerBandHigher implements IndicatorRule
{

  String name;
  int dataPoints;
  AboveBollingerBandHigher(this.name,this.dataPoints)
  {

  }
  bool IsMet(Iterable<Map> window,Map currentValue)
  {
    List<double> data = <double>[];
    for(Map day in window)
    {
      data.add(day["close"]);
    }
    if(BollingerUpper(data) < currentValue["high"])
      return true;
    else
      return false;
  }
}


class RandomRule implements IndicatorRule
{

  String name;
  int dataPoints;
  RandomRule(this.name,this.dataPoints)
  {

  }
  bool IsMet(Iterable<Map> window,Map currentValue)
  {
    var rng = new Random();
    if(rng.nextDouble()>0.5)
      return true;
    else
      return false;
  }
}


