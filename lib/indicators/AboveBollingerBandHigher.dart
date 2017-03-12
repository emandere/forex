part of indicator_library;
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
