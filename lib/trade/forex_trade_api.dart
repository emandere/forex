import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'dart:convert';
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
        Map priceJSON = await mongoLayer.readLatestPrice(pair);
        var price = new Price.fromJsonMap(priceJSON);
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