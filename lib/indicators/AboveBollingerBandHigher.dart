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
    List<double> data = dataFromWindow(window);
    if(BollingerUpper(data) < currentValue["high"])
      return true;
    else
      return false;
  }
  double indicator(Iterable<Map> window)=>BollingerUpper(dataFromWindow(window));
}
