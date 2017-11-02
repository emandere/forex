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
  var endDate="201300101";
  var pairs=await readMongoPairs(server);

  DateFormat formatter = new DateFormat('yyyyMMdd');

  
  for(String pair in pairs) 
  {
    var startCandleMap = await mongoLayer.readLatestCandle(pair);
    if(startCandleMap!=null)
    {
      var startCandle = new ForexDailyValue.fromJson(startCandleMap);
      startDate = formatter.format(startCandle.datetime.add(new Duration(days:-1)));
    }
    var url = 'http://$server/api/forexclasses/v1/dailypricesrange/$pair/$startDate/$endDate';

    var  listCandleJson = await http.get(url);
    List<Map> listCandleJSonMap = JSON.decode(listCandleJson.body);
    print(pair);
    for(Map candleJson in listCandleJSonMap)
    {
      ForexDailyValue dailyValue=new ForexDailyValue.fromJson(candleJson);
      await mongoLayer.AddCandle(dailyValue);

      String day=formatter.format(dailyValue.datetime);
      var urlPrice = 'http://$server/api/forexclasses/v1/dailyrealtimeprices/$pair/$day';
      var  listPriceJson = await http.get(urlPrice);
      List<Map> listPriceJSonMap = JSON.decode(listPriceJson.body);
      for(Map priceJson in listPriceJSonMap)
      {
           Price dailyPrice = new Price.fromJsonMap(priceJson);
           await mongoLayer.AddPrice(dailyPrice);
      }
      print(" $day");
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