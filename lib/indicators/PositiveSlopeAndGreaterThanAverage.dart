part of indicator_library;
class PositiveSlopeAndGreaterThanAverage implements IndicatorRule
{

  String name;
  int dataPoints;
  PositiveSlopeAndGreaterThanAverage(this.name,this.dataPoints)
  {

  }
  bool IsMet(Iterable<Map> window,Map currentValue)
  {
    List<double> data = dataFromWindow(window);
    if(Slope(data)>0 && Average(data) < currentValue["close"])
      return true;
    else
      return false;
  }
  double indicator(Iterable<Map> window)=>Average(dataFromWindow(window));
}