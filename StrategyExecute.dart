import 'dart:async';
import 'package:intl/intl.dart';
import 'lib/forex_mongo.dart';
import 'lib/forex_classes.dart';
import 'lib/forexclasses/forex_cache.dart';
import 'lib/forex_indicator_rules.dart';
import 'lib/forex_prices.dart';
main(List<String> arguments) async
{
  var arg = "debug";
  var isProcessing = false;
  if (arguments.length > 0)
    arg = arguments[0];
  ForexMongo mongoLayer = new ForexMongo(arg);
  await mongoLayer.db.open();




  PercentageComplete(DateTime currentDay, DateTime endDate,
      int sessionDuration) {
    Duration remainingTime = endDate.difference(currentDay);
    return ((sessionDuration - remainingTime.inDays) / sessionDuration) * 100.0;
  }

  ProcessTradingSession(ForexMongo mongoLayer) async
  {
    if(isProcessing)
      return;

    isProcessing=true;
    var tradingSessionMap = await mongoLayer.popTradingSession();
    if (tradingSessionMap != null) {
      TradingSession tradingSession = new TradingSession.fromJSONMap(
          tradingSessionMap);
      print(tradingSession.strategy.ruleName);

      IndicatorRule tradingRule = new IndicatorRule(
          tradingSession.strategy.ruleName, tradingSession.strategy.window);
      List<IndicatorRule> rules = new List<IndicatorRule>();
      rules.add(tradingRule);

      DateFormat formatter = new DateFormat('yyyyMMdd');
      int sessionRange = tradingSession.endDate
          .difference(tradingSession.currentTime)
          .inDays;
      ForexCache cache = new ForexCache(
          formatter.format(tradingSession.currentTime),
          formatter.format(tradingSession.endDate), rules);
      await cache.buildCacheMongo(mongoLayer);
      print("cache built!");

      for (var dailyPairValues in cache.DailyValues())
      {
        for (Map dailyPairValue in dailyPairValues)
        {
          if (dailyPairValue[tradingSession.strategy.ruleName])
          {
            tradingSession.executeTradeStrategyPrice("primary",
                tradingSession.strategy,
                new Price.fromJsonDailyValue(dailyPairValue));
          }

          await for (Map priceMap in mongoLayer.readPricesAsyncByDate(dailyPairValue['pair'], DateTime.parse(dailyPairValue['date'])))
          {
            tradingSession.updateSessionPriceNoHist(new Price.fromJsonMap(priceMap));
          }

          tradingSession.updateSession(dailyPairValues);
          await mongoLayer.saveSession(tradingSession);
          tradingSession.percentComplete = PercentageComplete(tradingSession.currentTime, tradingSession.endDate, sessionRange);
          print("${dailyPairValue['pair']} ${dailyPairValue['date']} ${tradingSession.percentComplete}");
        }
      }

      tradingSession.percentComplete = 100.0;
      tradingSession.printacc();
      await mongoLayer.saveSession(tradingSession);
    }
    isProcessing=false;
  }


  const period = const Duration(seconds: 3);
  new Timer.periodic(
      period, (Timer t) async => await ProcessTradingSession(mongoLayer));
}