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
    var open = window.map((t)=>t["open"]);
    var close = window.map((t)=>t["close"]);
    var RSIValue = RSI(new IterableZip([open,close]));
    var maxdiff = (new IterableZip([open,close])).map((t)=>(t[1]-t[0])/t[0]).reduce(min);
    if(RSIValue<30 && maxdiff > -0.03)
      return true;
    else
      return false;
  }
}