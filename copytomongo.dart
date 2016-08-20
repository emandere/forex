import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'lib/forex_classes.dart';
import 'lib/forex_mongo.dart';
import 'lib/candle_stick.dart';
main() async
{

  var result;
  List<String> pairs = ["AUDUSD","EURUSD","GBPUSD","NZDUSD","USDCAD","USDCHF","USDJPY"];
  ForexMongo mongoLayer= new ForexMongo();
  await mongoLayer.db.open();
  await mongoLayer.ClearForexValues();
  await mongoLayer.AddCurrencies(pairs);
  for(String pair in pairs)
  {
    List<String> strvalues = new File('data/' + pair + '/' + pair + 'dailyval.txt').readAsLinesSync();
    List<ForexDailyValue> dailyvals = new List<ForexDailyValue>();
    for (String line in strvalues)
    {
      ForexDailyValue val = new ForexDailyValue.fromString(line, pairName:pair);
      result = await mongoLayer.addForexDailyValue(val);
      print(result);
    }
  }
  await mongoLayer.db.close();

  exit(1);
}