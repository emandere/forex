import 'dart:async';
import 'lib/forex_mongo.dart';
import 'lib/forex_classes.dart';
main(List<String> arguments) async
{
  ForexMongo mongoLayer = new ForexMongo(arguments[0]);
  await mongoLayer.db.open();



  const period = const Duration(seconds: 3);
  new Timer.periodic(period, (Timer t) async => await ProcessTradingSession(mongoLayer));

}

ProcessTradingSession(ForexMongo mongoLayer) async
{
  Strategy strategy1 = new Strategy();
  strategy1.ruleName="aa ${new DateTime.now().toIso8601String()}";

  TradingSession tradingSession1 = new TradingSession();
  tradingSession1.strategy=strategy1;

  await mongoLayer.pushTradingSession(tradingSession1);

}