import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/forex_prices.dart';
import 'lib/forex_mongo.dart';
main(List<String> arguments) async
{
  ForexMongo mongoLayer = new ForexMongo(arguments[0]);
  await mongoLayer.db.open();

  var file = new File("keys");
  var authorization = {"Authorization": await file.readAsString()};

  var lastQuotes = <String,Price>{};
  List<String> pairs = ["AUD_USD","EUR_USD","GBP_USD","NZD_USD","USD_CAD","USD_CHF","USD_JPY"];

  Stream<Price> getquotes() async*
  {
    while(true)
    {
      for(String pair in pairs)
      {
        try {
          var text = await http.read(
              "https://api-fxtrade.oanda.com/v1/prices?instruments=$pair",
              headers: authorization);
          var jsonPrice = JSON.decode(text);
          var price = new Price.fromJsonMap(jsonPrice["prices"][0]);
          yield price;
        }
        catch(exception,stackTrace)
        {
             print(exception);
             print(stackTrace);
        }

      }
      await new Future.delayed(const Duration(seconds : 10));
    }
  }

   await for(Price currPrice in getquotes())
   {
        if(!lastQuotes.containsKey(currPrice.instrument)
            || !lastQuotes[currPrice.instrument].time.isAtSameMomentAs(currPrice.time))
        {
            await mongoLayer.AddPrice(currPrice);
            await mongoLayer.AddCurrentPrice(currPrice);
            lastQuotes[currPrice.instrument]=currPrice;
            print(currPrice.instrument+" "+currPrice.time.toIso8601String());
        }
   }

}