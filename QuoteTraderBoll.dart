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
  var file = new File("keys");
  var fileAccount = new File("accountBoll");
  var accountId = await fileAccount.readAsString();

  var combinedheaders =
  {
    "Authorization": await file.readAsString(),
    'Content-type' : 'application/json'
  };

  var url =  "https://api-fxtrade.oanda.com/v3/accounts/$accountId/orders";
  var arg = "debug";
  if(arguments.length>0)
     arg = arguments[0];
  ForexMongo mongoLayer = new ForexMongo(arg);
  await mongoLayer.db.open();




  var ruleName = "BelowBollingerBandLower";
  var window = 14;
  var rsiRule = new IndicatorRule(ruleName, window);
  var sessionId = "liveSessionBollReal";
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
  var takeProfitPct = 0.008;
  var stopLossPct = 0.007;
  var tradePosition = "short";
  var account = "primary";
  var units=500;

  for(String pair in pairs)
  {
      availableTrades[pair.replaceAll(new RegExp("_"),"")]=false;
  }

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
     tradingSession.fundAccount("primary",190.28);
     tradingSession.strategy.position=tradePosition;
     tradingSession.strategy.units = units;
     tradingSession.strategy.stopLoss=stopLoss;
     tradingSession.strategy.takeProfit =takeProfit;
     tradingSession.strategy.window=window;
     tradingSession.sessionType = SessionType.live;

  }


  Future<bool> checkRule(Price currPrice) async
  {
    var endDate = new DateTime.now();
    var startDate = endDate.add(new Duration(days:-window));

    //var dailyValuesMap = await mongoLayer.readPriceRangeAsyncByDate(currPrice.instrument, startDate, endDate).toList();
    var dailyValuesMap = await mongoLayer.readDailyAsyncByDate(currPrice.instrument, endDate);
    if(dailyValuesMap.isNotEmpty)
    {
      print (currPrice.instrument +" "+rsiRule.indicator(dailyValuesMap).toStringAsFixed(0));
      if (rsiRule.IsMet(dailyValuesMap, currPrice.toJson()))
      {
        print('Sell! ${findPair(pairs,currPrice.instrument)} ${currPrice.time.toIso8601String()}');
        return true;
      }
    }
    return false;
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

    return tradingSession.allTrades("primary")
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
        if(await checkRule(currPrice))
        {
          tradingSession.executeTradePrice(
              account,
              currPrice,
              units,
              tradePosition,
              stopLoss * currPrice.bid,
              takeProfit * currPrice.bid);

          await executeRealTrades(url,combinedheaders,
              findPair(pairs,currPrice.instrument),
              (stopLoss * currPrice.bid).toStringAsFixed(3),
              (takeProfit * currPrice.bid).toStringAsFixed(3),
              tradingSession.strategy);

          availableTrades[currPrice.instrument] = false;
        }
        tradingSession.updateSessionPrice(currPrice);
      }

      await mongoLayer.saveSession(tradingSession);
      tradingSessionMap = await mongoLayer.readSession(sessionId);
      tradingSession = new TradingSession.fromJSONMap(tradingSessionMap);

    }
  }

}


executeRealTrades (String url,
    Map combinedheaders,
    String instrument,
    String stopLoss,
    String takeProfit,
    Strategy strategy) async
{
  int side = strategy.position=="short"?-1:1;
  int units = side * strategy.units;
  var order =
  {
    "order":
    {
      "units":units.toString(),
      "instrument": instrument,
      "timeInForce": "FOK",
      "type": "MARKET",
      "positionFill": "DEFAULT",
      "stopLossOnFill":
      {
        "price": stopLoss
      },
      "takeProfitOnFill":
      {
        "price": takeProfit
      }
    }
  };
  var response = await http.post(url,body:JSON.encode(order),headers:combinedheaders);
  print("url: ${url}");
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");

}

String findPair(List<String> pairs,String instrument)
{
    return pairs.where((pair)=>pair.replaceAll(new RegExp("_"),"")==instrument).first;
}


