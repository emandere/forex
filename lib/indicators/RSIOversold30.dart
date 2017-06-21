part of indicator_library;
class RSIOversold30 implements IndicatorRule
{
  String name;
  int dataPoints;
  RSIOversold30(this.name,this.dataPoints)
  {

  }
  bool IsMet(Iterable<Map> window,Map currentValue)
  {
    var RSIValue = RSI(datafromZipWindow(window));
    if(RSIValue<30)
      return true;
    else
      return false;
  }

  double indicator(Iterable<Map> window)=>RSI(datafromZipWindow(window));
}