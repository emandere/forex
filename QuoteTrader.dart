import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'lib/forex_prices.dart';
import 'lib/forex_mongo.dart';
import 'lib/forex_classes.dart';
import 'lib/forex_indicator_rules.dart';
import 'lib/trade/forex_trade_api.dart';
main(List<String> arguments) async
{
  var arg = "debug";
  if(arguments.length>0)
     arg = arguments[0];
  ForexMongo mongoLayer = new ForexMongo(arg);
  await mongoLayer.db.open();




  var ruleName = "RSIOverbought70";
  var window = 14;
  var rsiRule = new IndicatorRule(ruleName, window);
  var sessionId = "liveSession";
  var server ="23.22.66.239";
  if(arg=="debug")
    server="localhost";
  else
    server="23.22.66.239";

  var tradingSessionMap = await mongoLayer.readSession(sessionId);
  var tradingSession = new TradingSession();
  var lastQuotes = <String,Price>{};
  var availableTrades=<String,bool>{};
  var pairs = ["AUD_USD","EUR_USD","GBP_USD","NZD_USD","USD_CAD","USD_CHF","USD_JPY"];
  var takeProfit = 1.0;
  var stopLoss = 1.0;
  var takeProfitPct = 0.003;
  var stopLossPct = 0.01;
  var tradePosition = "short";
  var account = "primary";
  var units=2000;


  if(tradePosition=="long")
  {
    takeProfit+=takeProfitPct;
    stopLoss-=stopLossPct;
  }
  else
  {
    takeProfit-=takeProfitPct;
    stopLoss+=stopLossPct;
  }

  if(tradingSessionMap!=null)
  {
    tradingSession = new TradingSession.fromJSONMap(tradingSessionMap);
  }
  else
  {
     tradingSession.id=sessionId;
     tradingSession.startDate = new DateTime.now();
     tradingSession.fundAccount("primary",2000.0);
  }


  Future<bool> checkRule(Price currPrice) async
  {
    var endDate = new DateTime.now();
    var startDate = endDate.add(new Duration(days:-window));

    var dailyValuesMap = await mongoLayer.readPriceRangeAsyncByDate(currPrice.instrument, startDate, endDate).toList();
    if(dailyValuesMap.isNotEmpty)
    {
      print (currPrice.instrument +" "+rsiRule.indicator(dailyValuesMap).toStringAsFixed(0));
      if (rsiRule.IsMet(dailyValuesMap, currPrice.toJson()))
      {
        print('Sell! ${currPrice.instrument} ${currPrice.time.toIso8601String()}');
        return true;
      }
    }
    return false;
  }

  Future<bool> checkRule2(Price p) async
  {
     return true;
  }

  bool newquote(Price currPrice)
  {
    if(!lastQuotes.containsKey(currPrice.instrument)
        || !lastQuotes[currPrice.instrument].time.isAtSameMomentAs(currPrice.time))
    {
      lastQuotes[currPrice.instrument]=currPrice;
      return true;
    }
    else
      return false;
  }

  bool pairTraded(Price price)
  {
    DateFormat formatter = new DateFormat('yyyyMMdd');
    return tradingSession.openTrades("primary")
        .where((trade)=>trade.pair==price.instrument)
        .map((trade)=>formatter.format(DateTime.parse(trade.openDate)))
        .contains(formatter.format(price.time));
  }


  await for(Price currPrice in getquotes(pairs,mongoLayer))
  {

    if(newquote(currPrice))
    {
      tradingSession.updateSessionPrice(currPrice);
      if(!pairTraded(currPrice))
      {
        availableTrades[currPrice.instrument]=true;
      }

      if(availableTrades[currPrice.instrument])
      {
        if (await checkRule(currPrice))
        {
          tradingSession.executeTradePrice(
              account,
              currPrice,
              units,
              tradePosition,
              stopLoss * currPrice.bid,
              takeProfit * currPrice.bid);
          availableTrades[currPrice.instrument] = false;
        }
        //tradingSession.printacc();
        tradingSession.updateSessionPrice(currPrice);
      }

      await mongoLayer.saveSession(tradingSession);
      tradingSessionMap = await mongoLayer.readSession(sessionId);
      tradingSession = new TradingSession.fromJSONMap(tradingSessionMap);
      //PostData myData = new PostData();
      //myData.data = tradingSession.toJson();

      //var url = 'http://$server/api/forexclasses/v1/addsessionpost';
      //var response = await http.post(url, body: myData.toJsonMap());
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");

    }
  }

}


