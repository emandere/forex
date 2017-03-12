part of indicator_library;
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