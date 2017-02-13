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
  ForexMongo mongoLayer;
  DateTime startDate;
  DateTime endDate;
  List<IndicatorRule> rules;
  ForexCache(this.mongoLayer,this.startDate,this.endDate,this.rules)
  {
    cache = {};
  }

  buildCache() async
  {
    await for(Map pairMap in mongoLayer.readMongoPairsAsync())
    {
      String pair = pairMap["name"];
      cache[pair] = <Map>[];
      await for(Map dailyvalueMap in mongoLayer.readDailyValuesRangeAsync(pair,startDate,endDate))
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
  //Map<String,List<Map>> cache = new Map<String,List<Map>>();
  ForexMongo mongoLayer = new ForexMongo("debug");
  await mongoLayer.db.open();
  DateTime startDate = DateTime.parse("2002-12-31");
  DateTime endDate = DateTime.parse("2012-01-01");
  List<IndicatorRule> rules = new List<IndicatorRule>();

  String ruleName = "PositiveSlopeAndGreaterThanAverage";

  IndicatorRule tradingRule = new IndicatorRule(ruleName,50);
  rules.add(tradingRule);
  ForexCache cache = new ForexCache(mongoLayer,startDate,endDate,rules);
  await cache.buildCache();
  print("cache built");
  cache.DailyValues();


  TradingSession testSession=new TradingSession();
  testSession.id="testSessionNewSlope01Order2";
  testSession.sessionUser.id="testSessionUserNewSlope";
  testSession.startDate = startDate;
  testSession.fundAccount("primary",2000.0);
  Stopwatch watch = new Stopwatch();
  watch.start();
  for(var dailyPairValues in cache.DailyValues())
  {
      for(Map dailyPairValue in dailyPairValues)
      {
        if(dailyPairValue[ruleName]) {

          testSession.executeTrade(
              "primary",
              dailyPairValue["pair"],
              10,
              "long",
              dailyPairValue["date"],
              0.99 * dailyPairValue["close"],
              1.05 * dailyPairValue["close"]);
        }
      }
      testSession.updateSession(dailyPairValues);
      //print(dailyPairValues.first["date"]);
  }
  watch.stop();

  testSession.printacc();
  print(watch.elapsedMilliseconds.toString());


  PostData myData = new PostData();
  myData.data=testSession.toJson();

  var url = "http://23.22.66.239/api/forexclasses/v1/addsessionpost";
  var response = await http.post(url,body:myData.toJsonMap());
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");

  exit(1);

}