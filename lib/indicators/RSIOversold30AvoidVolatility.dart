part of indicator_library;
class RSIOversold30AvoidVolatility implements IndicatorRule
{
  String name;
  int dataPoints;
  RSIOversold30AvoidVolatility(this.name,this.dataPoints)
  {

  }
  bool IsMet(Iterable<Map> window,Map currentValue)
  {
    var RSIValue = RSI(datafromZipWindow(window));
    var maxdiff = datafromZipWindow(window).map((t)=>(t[1]-t[0])/t[0]).reduce(min);
    if(RSIValue<30 && maxdiff > -0.03)
      return true;
    else
      return false;
  }
  double indicator(Iterable<Map> window)=>RSI(datafromZipWindow(window));
}