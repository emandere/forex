import 'dart:io';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import 'lib/forex_mongo.dart';
import 'lib/forex_prices.dart';
import 'lib/candle_stick.dart';


main(List<String> arguments) async
{
  ForexMongo mongoLayer = new ForexMongo(arguments[0]);
  await mongoLayer.db.open();

  var pairs = await mongoLayer.readMongoPairs();

  for(var pair in pairs)
  {
     print(pair);
     var latestDateMap = await mongoLayer.readLatestCandle(pair);
     if(latestDateMap == null)
     {
        await CreateAllCandles(pair,mongoLayer);
     }
     else
     {
       var latestDate = new ForexDailyValue.fromJson(latestDateMap);
       await CreateLatestCandles(pair,latestDate, mongoLayer);
     }
  }

  exit(0);
}

CreateAllCandles(String pair,ForexMongo mongoLayer) async
{

  DateFormat formatter = new DateFormat('yyyyMMdd');

  var days = new Set();
  await for(Map priceMap in mongoLayer.readPricesAsync(pair))
  {
        Price price = new Price.fromJsonMap(priceMap);
        String daydt=formatter.format(price.time);
        days.add(DateTime.parse(daydt));
  }


  for(DateTime day in days)
  {
      print(day.toUtc().toString());
      await CreateCandle(pair,day,mongoLayer);
  }
}

CreateLatestCandles(String pair,ForexDailyValue latestValue, ForexMongo mongoLayer) async
{
  DateFormat formatter = new DateFormat('yyyyMMdd');

  var days = new Set();
  await for(Map priceMap in mongoLayer.readPricesAsyncLatest(pair,latestValue.datetime))
  {
    Price price = new Price.fromJsonMap(priceMap);
    String daydt=formatter.format(price.time);
    days.add(DateTime.parse(daydt));
  }


  for(DateTime day in days)
  {
    print(day.toUtc().toString());
    await CreateCandle(pair,day,mongoLayer);
  }

}


CreateCandle(String pair,DateTime day,ForexMongo mongoLayer) async
{
   ForexDailyValue dailyValue = new ForexDailyValue()
      ..pair = pair
      ..date = day.toUtc().toString()
      ..datetime =day
      ..open = new Price.fromJsonMap(await mongoLayer.readPricesAsyncByDate(pair, day).first).ask
      ..close = new Price.fromJsonMap(await mongoLayer.readPricesAsyncByDate(pair, day).last).ask
      ..high = await mongoLayer.readPricesAsyncByDate(pair, day).map((x)=> x["ask"]).reduce(max)
      ..low = await mongoLayer.readPricesAsyncByDate(pair, day).map((x)=> x["ask"]).reduce(min);

   await mongoLayer.AddCandle(dailyValue);
   print('${dailyValue.pair}  ${dailyValue.date} ${dailyValue.open.toString()} '
       ' ${dailyValue.high.toString()} ${dailyValue.low.toString()} ${dailyValue.close.toString()}');

}