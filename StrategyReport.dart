import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'lib/forex_classes.dart';
import 'lib/forex_mongo.dart';
import 'lib/candle_stick.dart';
import 'testStats.dart';

class IndicatorRule
{
   String name;
   int dataPoints;
   IndicatorRule(this.name,this.dataPoints)
   {

   }

   bool isMet(List<Map> window,Map currentValue)
   {
      List<double> data = new List<double>();
      for(Map day in window)
      {
          data.add(day["close"]);
      }
      if(Average(data) < currentValue["close"])
          return true;
      else
          return false;
   }

}

class ForexCache
{
  Map<String,List<Map>> cache;
  ForexMongo mongoLayer;
  DateTime startDate;
  DateTime endDate;
  List<IndicatorRule> rules;
  ForexCache(this.mongoLayer,this.startDate,this.endDate,this.rules)
  {
    cache = new Map<String,List<Map>>();
  }

  buildCache() async
  {
    await for(Map pairMap in mongoLayer.readMongoPairsAsync())
    {
      String pair = pairMap["name"];
      cache[pair] = new List<Map>();

      await for(Map dailyvalueMap in mongoLayer.readDailyValuesRangeAsync(pair,startDate,endDate))
      {
        cache[pair].add(dailyvalueMap);
      }
    }

  }

  Stream DailyValues() async*
  {
      int cacheSize = cache.values.first.length;

      for(int i=0;i<cacheSize;i++)
      {
        var values = new Map<String,List<Map>>();
        String dailyValuesDate = cache.values.first[i]["date"];
        values[dailyValuesDate]=new List<Map>();
        for(String pair in cache.keys)
        {
             Map dailyValue = new Map();
             for(var key in cache[pair][i].keys)
             {
               dailyValue[key] = cache[pair][i][key];
               //dailyValue["close"] = cache[pair][i]["close"];
             }
             for(IndicatorRule rule in rules)
             {
                  if(i>=rule.dataPoints)
                  {
                    var data = cache[pair].getRange(i-rule.dataPoints,i);
                    dailyValue[rule.name] = checkRule(rule,data,cache[pair][i]);
                  }
                  else
                  {
                    dailyValue[rule.name]=false;
                  }
             }
             values[dailyValuesDate].add(dailyValue);
        }
        yield values;
      }
  }

  bool checkRule(IndicatorRule rule, Iterable dataList,Map dailyValue)
  {
        return rule.isMet(dataList.toList(),dailyValue);
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
  IndicatorRule greaterthan50Avg = new IndicatorRule("gthan50",50);
  rules.add(greaterthan50Avg);
  ForexCache cache = new ForexCache(mongoLayer,startDate,endDate,rules);
  await cache.buildCache();
  print("cache built");

  TradingSession testSession=new TradingSession();
  testSession.id="testSessionNew";
  testSession.sessionUser.id="testSessionUserNew";
  testSession.fundAccount("primary",2000.0);
  await for(Map values in cache.DailyValues())
  {
    for(Map pairvalues in values.values.first)
    {
        if(pairvalues["gthan50"]) {
          testSession.executeTrade(
              "primary",
              pairvalues["pair"],
              10,
              "long",
              pairvalues["date"],
              0.9 * pairvalues["close"],
              1.1 * pairvalues["close"]);
        }
    }
    testSession.updateSession(values.keys.first,values.values.first);
  }

  testSession.printacc();

  PostData myData = new PostData();
  myData.data=testSession.toJson();

  var url = "http://23.22.66.239/api/forexclasses/v1/addsessionpost";
  var response = await http.post(url,body:myData.toJsonMap());
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");

  /*await for(Map values in cache.DailyValues())
  {
    String closePrices=" ";
    for(Map pairvalues in values.values.first)
    {
       closePrices+=pairvalues.keys.map((key)=>pairvalues[key].toString())
                                   .reduce((t,e)=>t+":"+e)+" ";
    }
    //print (values.keys.first + closePrices);
  }*/

  exit(1);

}