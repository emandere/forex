import 'package:test/test.dart';
import 'lib/forex_strategy_class.dart';
void main()
{
  test("Test Strategy Class",testStrategyConstructor);
}

testStrategyConstructor()
{
    var testMap ={};
    testMap["ruleName"]="RSIOverbought70";
    testMap["window"]=100;
    testMap["stopLoss"]=0.03;
    testMap["takeProfit"]=0.01;
    Strategy test = new Strategy.fromJsonMap(testMap);
    expect(test.rule.name,"RSIOverbought70");
    expect(test.rule.dataPoints, 100);


    Map testJSONOut = test.toJson();
    Strategy test2 = new Strategy.fromJsonMap(testJSONOut);
    expect(test2.rule.name,"RSIOverbought70");
    expect(test2.rule.dataPoints, 100);

}