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
    List<double> data = dataFromWindow(window);
    if(BollingerLower(data) > currentValue["close"])
      return true;
    else
      return false;
  }
  double indicator(Iterable<Map> window)=>BollingerLower(dataFromWindow(window));
}