import 'dart:async';
import 'dart:io';
import 'lib/forex_mongo.dart';
import 'lib/forex_classes.dart';
main(List<String> arguments) async
{
  ForexMongo mongoLayer = new ForexMongo(arguments[0]);
  await mongoLayer.db.open();



  //const period = const Duration(seconds: 3);
  //new Timer.periodic(period, (Timer t) async => await ProcessTradingSession(mongoLayer));
  await ProcessTradingSession(mongoLayer);
  exit(1);
}

ProcessTradingSession(ForexMongo mongoLayer) async
{
  Strategy strategy1 = setStrategy("RSIOverbought70","short",14);
  /*strategy1.ruleName="RSIOverbought70";
  strategy1.window=14;
  strategy1.position="short";*/


  TradingSession tradingSession1 = new TradingSession();
  tradingSession1.strategy=strategy1;
  tradingSession1.startDate=DateTime.parse("20170101");
  tradingSession1.endDate=DateTime.parse("20171201");
  tradingSession1.fundAccount("primary", 2000.0);

  await mongoLayer.pushTradingSession(tradingSession1);


}


setStrategy(String ruleName,String rulePosition,int window)
{

  double takeProfitPct = 0.001;
  double stopLossPct = 0.03;

  double takeProfit = 1.0;
  double stopLoss = 1.0;


  if(rulePosition=="long")
  {
    takeProfit+=takeProfitPct;
    stopLoss-=stopLossPct;
  }
  else
  {
    takeProfit-=takeProfitPct;
    stopLoss+=stopLossPct;
  }

  int units = 2000;
  Strategy testStrategies = new Strategy();
  testStrategies.ruleName=ruleName;
  testStrategies.position="short";
  testStrategies.window=window;
  testStrategies.stopLoss=stopLoss;
  testStrategies.takeProfit=takeProfit;
  testStrategies.units=units;
  return testStrategies;
}