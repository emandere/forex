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
    var open = window.map((t)=>t["open"]);
    var close = window.map((t)=>t["close"]);
    var RSIValue = RSI(new IterableZip([open,close]));
    if(RSIValue>70)
      return true;
    else
      return false;
  }
}