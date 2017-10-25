import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'lib/forex_mongo.dart';
import 'lib/forex_prices.dart';
import 'lib/candle_stick.dart';

main() async
{
  ForexMongo mongoLayer = new ForexMongo("debug");
  await mongoLayer.db.open();
  var server= "23.22.66.239";
  var startDate="20110101";
  var endDate="20300101";
  var pairs=await readMongoPairs(server);
  
  for(String pair in pairs) 
  {
    var url = 'http://$server/api/forexclasses/v1/dailypricesrange/$pair/$startDate/$endDate';
    var  listCandleJson = await http.get(url);
    List<Map> listCandleJSonMap = JSON.decode(listCandleJson.body);
    print(pair);
    for(Map candleJson in listCandleJSonMap)
    {
      print(candleJson["close"].toString());
      ForexDailyValue dailyValue=new ForexDailyValue.fromJson(candleJson);
      await mongoLayer.AddCandle(dailyValue);
      var dat = dailyValue.datetime.toIso8601String();
      print(" $dat");
    }

  }

  exit(1);
}

readMongoPairs(String server) async
{
  var pairurl = 'http://$server/api/forexclasses/v1/pairs';
  var pairsListStr = await http.get(pairurl);
  return JSON.decode(pairsListStr.body);
}