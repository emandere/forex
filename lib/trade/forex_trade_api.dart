import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../forex_prices.dart';
import '../forex_mongo.dart';
import '../forex_classes.dart';
import '../forex_indicator_rules.dart';
Stream<Price> getquotes(List<String> pairs,ForexMongo mongoLayer) async*
{
  while(true)
  {
    for(String pair in pairs)
    {
      try {
        Map priceJSON = await mongoLayer.readLatestPrice(pair.replaceAll(new RegExp("_"),""));
        var price = new Price.fromJsonMap(priceJSON);
        print("Running at ${ new DateTime.now().toIso8601String()}");
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


Stream<Price> getquotes2(List<String> pairs,ForexMongo mongoLayer) async*
{
  var genDates = new List<DateTime>.generate(10, (int index)=>new DateTime.now().add(new Duration(days: index)));
  var rng = new Random();
  for(String pair in pairs)
  {
    for(DateTime dt in genDates)
    {
       var price = new Price()
                    ..instrument=pair
                    ..time=dt
                    ..bid=rng.nextDouble();
       yield price;

    }
    await new Future.delayed(const Duration(seconds : 10));
  }

}