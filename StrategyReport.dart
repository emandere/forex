import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'lib/forex_classes.dart';
import 'lib/forex_mongo.dart';
import 'lib/candle_stick.dart';
import 'lib/forex_stats.dart';
import 'lib/forex_prices.dart';
import 'lib/forex_indicator_rules.dart';
import 'dart:collection';
import 'lib/forexclasses/forex_cache.dart';



main() async
{
  String server ="localhost";//"23.22.66.239";
  String account = "primary";


  String startDate = "2017-05-20";
  String endDate = "2018-01-01";

  String ruleName = "RSIOverbought70";
  String rulePosition="short";
  int window = 14;
  Strategy testStrategies = setStrategy(ruleName, rulePosition, window);






  IndicatorRule tradingRule = new IndicatorRule(ruleName,window);
  List<IndicatorRule> rules = new List<IndicatorRule>();
  rules.add(tradingRule);

  ForexCache cache = new ForexCache(startDate,endDate,rules);
  await cache.buildCache(server);

  print("cache built");
  cache.DailyValues();


  TradingSession testSession=new TradingSession();
  testSession.id=ruleName+"-2000";
  testSession.sessionUser.id="testSessionUserNewSlope";
  testSession.startDate = DateTime.parse(startDate);
  testSession.strategy=testStrategies;
  testSession.fundAccount("primary",2000.0);
  Stopwatch watch = new Stopwatch();
  watch.start();

  for(var dailyPairValues in cache.DailyValues())
  {
    for(Map dailyPairValue in dailyPairValues)
    {
      if(dailyPairValue[ruleName])
      {
        testSession.executeTradeStrategyPrice(account, testStrategies, new Price.fromJsonDailyValue(dailyPairValue));
      }
    }
    testSession.updateSession(dailyPairValues);
  }
  watch.stop();

  balanceHistPair( testSession,"USDJPY");


  testSession.printacc();
  print(watch.elapsedMilliseconds.toString());


  PostData myData = new PostData();
  myData.data=testSession.toJson();

  var url = 'http://$server/api/forexclasses/v1/addsessionpost';
  var response = await http.post(url,body:myData.toJsonMap());
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");

  exit(1);

}


setStrategy(String ruleName,String rulePosition,int window)
{

  double takeProfitPct = 0.003;
  double stopLossPct = 0.01;

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


List balanceHistPair(TradingSession currentSession,String pair)
{
  List pairBalanceHistory = [];
  findClosedTrades(String date)
  {
    return currentSession
        .sessionUser
        .closedTrades()
        .where((trade)=>trade.pair==pair)
        .where((trade)=>trade.closeDate==date);
  }

  var sessionDates = currentSession
      .sessionUser
      .primaryAccount
      .balanceHistory
      .map((dailyVal)=>dailyVal["date"]);

  double amount = currentSession
      .sessionUser
      .primaryAccount
      .balanceHistory[0]["amount"];

  for(String sessionDate in sessionDates)
  {
    pairBalanceHistory.add([DateTime.parse(sessionDate),amount]);
    if(findClosedTrades(sessionDate).isNotEmpty)
    {
      amount += findClosedTrades(sessionDate)
          .map((trade) => trade.PL())
          .reduce((t, e) => t + e);
    }
  }

  return pairBalanceHistory;
}