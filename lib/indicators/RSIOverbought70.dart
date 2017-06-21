part of indicator_library;
class RSIOverbought70 implements IndicatorRule
{
  String name;
  int dataPoints;
  RSIOverbought70(this.name,this.dataPoints)
  {

  }
  bool IsMet(Iterable<Map> window,Map currentValue)
  {
    var RSIValue = RSI(datafromZipWindow(window));
    if(RSIValue>70)
      return true;
    else
      return false;
  }

  double indicator(Iterable<Map> window)=>RSI(datafromZipWindow(window));
}