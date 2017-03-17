import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'lib/forex_classes.dart';
import 'lib/forex_mongo.dart';
import 'lib/candle_stick.dart';
import 'lib/forex_stats.dart';
import 'lib/forex_indicator_rules.dart';
import 'dart:collection';
import "package:collection/collection.dart";

class ForexCache
{
  Map cache;
  //ForexMongo mongoLayer;
  String startDate;
  String endDate;
  List<IndicatorRule> rules;
  ForexCache(this.startDate,this.endDate,this.rules)
  {
    cache = {};
  }

  readMongoPairs(String server) async
  {
    var pairurl = 'http://$server/api/forexclasses/v1/pairs';
    var pairsListStr = await http.get(pairurl);
    return JSON.decode(pairsListStr.body);
  }

  readDailyValuesRangeAsync(String server,String pair,String startDate,String endDate) async
  {
    var pairurl = 'http://$server/api/forexclasses/v1/dailyvaluesrange/$pair/$startDate/$endDate';
    var pairsListStr = await http.get(pairurl);
    return JSON.decode(pairsListStr.body);
  }

  buildCache(String server) async
  {
    for(String pair in await readMongoPairs(server))
    {
      cache[pair] = <Map>[];
      for(Map dailyvalueMap in await readDailyValuesRangeAsync(server,pair,startDate,endDate))
      {
        cache[pair].add(dailyvalueMap);
      }
    }
  }

  DailyValues()
  {
      GetPosition(pair,date)=>cache[pair].map((dailyvalue)=>dailyvalue['date']
                                         .toString())
                                         .toList()
                                         .indexOf(date);
      GetDailyValue(pair,date)=>cache[pair][GetPosition(pair,date)];
      GetRange(pair,date,dataPoints)=>cache[pair].getRange(GetPosition(pair,date)-dataPoints,GetPosition(pair,date));
      GetRuleResult(pair,date,rule,dataPoints)
      {
        if (GetPosition(pair,date) >= dataPoints)
        {
          return rule.IsMet(GetRange(pair, date, dataPoints), GetDailyValue(pair, date));
        }
        else
        {
          return false;
        }
      }

      addRules(List dailyValues)
      {
        for(Map dailyValue in dailyValues )
        {
          for (var rule in rules)
          {
              dailyValue[rule.name]=GetRuleResult(dailyValue['pair'],dailyValue['date'],rule,rule.dataPoints);
          }
        }
        return dailyValues;
      }

      var dailyValuesZip = new IterableZip(cache.values);
      return dailyValuesZip.map(addRules);
  }




}

main() async
{
  String server ="23.22.66.239";
  String startDate = "2002-12-31";
  String endDate = "2012-01-01";
  String rulePosition="short";
  String ruleName = "RSIOverbought70";
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
  cache.DailyValues();


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
        if(dailyPairValue[ruleName]) {

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

  var url = 'http://$server/api/forexclasses/v1/addsessionpost';
  var response = await http.post(url,body:myData.toJsonMap());
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");

  exit(1);

}