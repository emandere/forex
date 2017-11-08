import 'dart:convert';
import 'forex_indicator_rules.dart';
class Strategy
{
  String ruleName;
  int window;
  int units;
  IndicatorRule rule;
  double stopLoss;
  double takeProfit;
  Map toJson()
  {
    return
      {
        "ruleName":ruleName,
        "window":window,
        "units":units,
        "stopLoss":stopLoss,
        "takeProfit":takeProfit
      };
  }

  Strategy()
  {

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
    rule = new IndicatorRule(ruleName, window);
  }
}