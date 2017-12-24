import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import "package:collection/collection.dart";
import '../forex_indicator_rules.dart';
import '../forex_mongo.dart';
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

  Future <List<Map>> dailyValuesRange(ForexMongo mongoLayer,String pair,String startDate,String endDate) async
  {
    List<Map> dailyvals=new List<Map>();
    await for(Map dailyvalueMap in mongoLayer.readDailyValuesRangeAsync(pair,DateTime.parse(startDate),DateTime.parse(endDate)))
    {
      dailyvals.add(dailyvalueMap);
    }
    await for(Map dailyvalueMap in mongoLayer.readDailyValuesRangeAsyncLatest(pair,DateTime.parse(startDate),DateTime.parse(endDate)))
    {
      dailyvals.add(dailyvalueMap);
    }
    return dailyvals;
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

  buildCacheMongo(ForexMongo mongoLayer) async
  {
    for(String pair in await mongoLayer.readMongoPairs())
    {
      cache[pair] = <Map>[];
      for(Map dailyvalueMap in await dailyValuesRange(mongoLayer,pair, startDate,endDate))//readDailyValuesRangeAsync(server,pair,startDate,endDate))
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