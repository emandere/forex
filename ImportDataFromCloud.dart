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
import 'lib/forex_classes.dart';

main(List<String> arguments) async
{
  var arg = "debug";

  if (arguments.length > 0)
    arg = arguments[0];

  ForexMongo mongoLayer = new ForexMongo(arg);
  print("Starting Import Server");
  await syncMongo(mongoLayer);
  print("Done with initial sync");
  while(true)
  {
    await syncMongo(mongoLayer);
    await new Future.delayed(const Duration(minutes: 30));
  }

}


syncMongo(ForexMongo mongoLayer) async
{

  await mongoLayer.db.open();
  var server= "23.22.66.239";
  var startDate="20110101";
  var endDate="20300101";
  var pairs=await readMongoPairs(server);
  bool shouldUpdate = false;
  for(String pair in pairs)
  {
    var localCurrPriceMap = await mongoLayer.readLatestPrice(pair);
    if(localCurrPriceMap==null)
    {
      shouldUpdate = true;
      break;
    }
    var urlLatest = 'http://$server/api/forexclasses/v1/latestprices/$pair';
    var priceJSON = await http.get(urlLatest);
    Price currPrice = new Price.fromJson(priceJSON.body);
    
    Price localPrice = new Price.fromJsonMap(localCurrPriceMap);
    if(currPrice.time.isAfter(localPrice.time))
    {
      shouldUpdate = true;
      break;
    }
  }

  if(!shouldUpdate) return;

  DateFormat formatter = new DateFormat('yyyyMMdd');

  print("Loading Sessions");
  var urlSessions = 'http://$server/api/forexclasses/v1/sessions';
  var  listSessionJson = await http.get(urlSessions);
  List<Map> listSessionJsonMap = JSON.decode(listSessionJson.body);
  for(Map sessionJSON in listSessionJsonMap)
  {
    TradingSession session = new TradingSession.fromJSONMap(sessionJSON);
    if(session.id=="liveSessionRSI" || session.id=="liveSessionRSIReal")
      session.sessionType = SessionType.live;
    await mongoLayer.saveSession(session);
    print("  Session ${session.id} saved");
  }
  print("Loading Sessions Complete");

  
 for(String pair in pairs)
  {
    var urlLatest = 'http://$server/api/forexclasses/v1/latestprices/$pair';
    var priceJSON = await http.get(urlLatest);
    Price currPrice = new Price.fromJson(priceJSON.body);
    await mongoLayer.AddCurrentPrice(currPrice);

    var startCandleMap = await mongoLayer.readLatestCandle(pair);
    var startDatePair=startDate;
    if(startCandleMap!=null)
    {
      var startCandle = new ForexDailyValue.fromJson(startCandleMap);
      startDatePair = formatter.format(startCandle.datetime.add(new Duration(days:-1)));
    }

    var url = 'http://$server/api/forexclasses/v1/dailypricesrange/$pair/$startDatePair/$endDate';

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

}

readMongoPairs(String server) async
{
  var pairurl = 'http://$server/api/forexclasses/v1/pairs';
  var pairsListStr = await http.get(pairurl);
  return JSON.decode(pairsListStr.body);
}
