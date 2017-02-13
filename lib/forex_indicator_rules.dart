import 'forex_stats.dart';
abstract class IndicatorRule
{
  factory IndicatorRule(String ruleName,int dataPoints)
  {
      switch(ruleName)
      {
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


