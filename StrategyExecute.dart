import 'dart:async';
import 'lib/forex_mongo.dart';
import 'lib/forex_classes.dart';
main(List<String> arguments) async
{
  ForexMongo mongoLayer = new ForexMongo(arguments[0]);
  await mongoLayer.db.open();

  Strategy strategy1 = new Strategy();
  Strategy strategy2 = new Strategy();

  strategy1.ruleName="aa";
  strategy2.ruleName="bb";

  TradingSession tradingSession1 = new TradingSession();
  TradingSession tradingSession2 = new TradingSession();

  tradingSession1.strategy=strategy1;
  tradingSession2.strategy=strategy2;
  await mongoLayer.pushTradingSession(tradingSession1);
  await mongoLayer.pushTradingSession(tradingSession2);

  const period = const Duration(seconds: 10);
  new Timer.periodic(period, (Timer t) async => await ProcessTradingSession(mongoLayer));

}

ProcessTradingSession(ForexMongo mongoLayer) async
{
    var tradingSessionMap = await mongoLayer.popTradingSession();

    if(tradingSessionMap!=null)
    {
      TradingSession tradingSession = new TradingSession.fromJSONMap(tradingSessionMap);
      print(tradingSession.strategy.ruleName);
    }
}