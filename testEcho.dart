import 'dart:isolate';

import 'lib/forex_indicator_rules.dart';
import 'lib/forex_classes.dart';
import 'lib/forex_cache.dart';
main(List<String> args, SendPort replyTo) async
{
  String server ="23.22.66.239";
  String startDate = "2002-12-31";
  String endDate = "2012-01-01";
  String rulePosition="long";
  String ruleName = args[0];
  String account = "primary";

  double takeProfitPct = 0.003;
  double stopLossPct = 0.01;
  double takeProfit = 1.0;
  double stopLoss = 1.0;

  int window = 14;

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

  int units = 15000;

  IndicatorRule tradingRule = new IndicatorRule(ruleName,window);
  List<IndicatorRule> rules = new List<IndicatorRule>();
  rules.add(tradingRule);

  ForexCache cache = new ForexCache(startDate,endDate,rules);
  await cache.buildCache(server);
  print("cache built");
  TradingSession testSession=new TradingSession();
  testSession.id='testSession$ruleName';
  testSession.sessionUser.id="testSessionUserNewSlope";
  testSession.startDate = DateTime.parse(startDate);
  testSession.fundAccount("primary",2000.0);
  Stopwatch watch = new Stopwatch();
  watch.start();
  var currentyear = "0";
  for(var dailyPairValues in cache.DailyValues())
  {
    for(Map dailyPairValue in dailyPairValues)
    {
      if(dailyPairValue[ruleName])
      {
        testSession.executeTrade(
          account,
          dailyPairValue["pair"],
          units,
          rulePosition,
          dailyPairValue["date"],
          dailyPairValue["close"],
          stopLoss * dailyPairValue["close"],
          takeProfit * dailyPairValue["close"]);
      }
    }
    testSession.updateSession(dailyPairValues);
  }
  watch.stop();
  testSession.printacc();
  print(watch.elapsedMilliseconds.toString());
  PostData myData = new PostData();
  myData.data=testSession.toJson();

  replyTo.send(args[0]+" Isolate Completed");
 
}