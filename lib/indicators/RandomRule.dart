part of indicator_library;
class RandomRule implements IndicatorRule
{

  String name;
  int dataPoints;
  RandomRule(this.name,this.dataPoints)
  {

  }
  bool IsMet(Iterable<Map> window,Map currentValue)
  {
    var rng = new Random();
    if(rng.nextDouble()>0.5)
      return true;
    else
      return false;
  }
}
