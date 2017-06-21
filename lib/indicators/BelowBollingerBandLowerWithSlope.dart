part of indicator_library;
class BelowBollingerBandLowerWithSlope implements IndicatorRule
{

  String name;
  int dataPoints;
  BelowBollingerBandLowerWithSlope(this.name,this.dataPoints)
  {

  }
  bool IsMet(Iterable<Map> window,Map currentValue)
  {
    List<double> data = dataFromWindow(window);
    if(Slope(data)>0  && BollingerLower(data) > currentValue["low"])
      return true;
    else
      return false;
  }
  double indicator(Iterable<Map> window)=>BollingerLower(dataFromWindow(window));
}
