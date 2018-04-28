part of forex_classes;
class Strategy
{
  String ruleName;
  String position;
  int window;
  int units;

  double stopLoss;
  double takeProfit;



  String toJson()
  {
     return JSON.encode(toJsonMap());
  }

  Map toJsonMap()
  {
    return
      {
        "ruleName":ruleName,
        "window":window,
        "units":units,
        "stopLoss":stopLoss,
        "takeProfit":takeProfit,
        "position":position
      };
  }

  Strategy()
  {
    ruleName = "default";
    window =0 ;
    units = 0 ;
    stopLoss =0.0;
    takeProfit = 0.0;
    position="long";
  }

  Strategy.fromJson(String json)
  {
    Map jsonNode = JSON.decode(json);
    setStrategy(jsonNode);
  }

  Strategy.fromJsonMap(Map jsonMap)
  {
    setStrategy(jsonMap);
  }

  setStrategy(Map jsonNode)
  {
    ruleName = jsonNode["ruleName"].toString();
    window = int.parse(jsonNode["window"].toString()) ;
    units = int.parse(jsonNode["units"].toString()) ;
    stopLoss =double.parse( jsonNode["stopLoss"].toString());
    takeProfit = double.parse(jsonNode["takeProfit"].toString());
    position=jsonNode["position"].toString();

  }
}