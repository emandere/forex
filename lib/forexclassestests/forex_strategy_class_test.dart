import 'package:test/test.dart';
import '../forex_classes.dart';
class TestStrategyClass
{
  testSuite()
  {
    test("Test Strategy Class Constructor",testStrategyConstructor);
  }

  testStrategyConstructor()
  {
    var testMap ={};
    testMap["ruleName"]="RSIOverbought70";
    testMap["window"]=100;
    testMap["stopLoss"]=0.03;
    testMap["takeProfit"]=0.01;
    testMap["units"]=2000;
    testMap["position"]="long";

    Strategy test = new Strategy.fromJsonMap(testMap);
    expect(test.rule.name,"RSIOverbought70");
    expect(test.rule.dataPoints, 100);
    expect(test.units, 2000);
    expect(test.position, "long");

    Map testJSONOut = test.toJson();
    Strategy test2 = new Strategy.fromJsonMap(testJSONOut);
    expect(test2.rule.name,"RSIOverbought70");
    expect(test2.rule.dataPoints, 100);
    expect(test2.units, 2000);
    expect(test2.position, "long");
  }
}