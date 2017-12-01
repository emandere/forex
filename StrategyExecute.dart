import 'dart:async';
import 'package:intl/intl.dart';
import 'lib/forex_mongo.dart';
import 'lib/forex_classes.dart';
import 'lib/forexclasses/forex_cache.dart';
import 'lib/forex_indicator_rules.dart';
import 'lib/forex_prices.dart';
main(List<String> arguments) async
{
  ForexMongo mongoLayer = new ForexMongo(arguments[0]);
  await mongoLayer.db.open();

  const period = const Duration(seconds: 3);
  new Timer.periodic(period, (Timer t) async => await ProcessTradingSession(mongoLayer));

}

ProcessTradingSession(ForexMongo mongoLayer) async
{
    var tradingSessionMap = await mongoLayer.popTradingSession();
    var server = "23.22.66.239";
    if(tradingSessionMap!=null)
    {
      TradingSession tradingSession = new TradingSession.fromJSONMap(tradingSessionMap);
      print(tradingSession.strategy.ruleName);

      IndicatorRule tradingRule = new IndicatorRule(tradingSession.strategy.ruleName,tradingSession.strategy.window);
      List<IndicatorRule> rules = new List<IndicatorRule>();
      rules.add(tradingRule);

      DateFormat formatter = new DateFormat('yyyyMMdd');

      ForexCache cache = new ForexCache(
          formatter.format(tradingSession.startDate),
          formatter.format(tradingSession.endDate),rules);
      await cache.buildCache(server);
      print("cache built!");

      for(var dailyPairValues in cache.DailyValues())
      {
        for(Map dailyPairValue in dailyPairValues)
        {
          if(dailyPairValue[tradingSession.strategy.ruleName])
          {
            tradingSession.executeTradeStrategyPrice("primary",
                tradingSession.strategy, new Price.fromJsonDailyValue(dailyPairValue));
          }
        }
        tradingSession.updateSession(dailyPairValues);
      }

      tradingSession.printacc();
    }
}