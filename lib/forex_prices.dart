import 'dart:convert';
class Price
{
  String instrument;
  DateTime time;
  double bid;
  double ask;
  String indicator;
  Map toJson()
  {
    return
      {
        "_id":instrument+time.toIso8601String(),
        "instrument":instrument,
        "time":time,
        "bid":bid,
        "ask":ask
      };
  }

  Price()
  {

  }

  Price.fromJson(String json)
  {
    Map jsonNode = JSON.decode(json);
    setPrice(jsonNode);
  }

  Price.fromJsonMap(Map jsonMap)
  {
     setPrice(jsonMap);
  }

  Price.fromJsonMapV2(Map jsonMap)
  {
    setPriceV2(jsonMap);
  }

  Price.fromJsonDailyValue(Map dailyPairValue)
  {
      instrument=dailyPairValue["pair"];
      bid=dailyPairValue["close"];
      ask=dailyPairValue["close"];
      time=dailyPairValue["datetime"];
  }

  setPriceV2(Map jsonNode)
  {
      List<Map> candles = jsonNode["candles"];
      Map lastCandle = candles.last;
      var lastTimeString = lastCandle["time"].toString().split(".")[0]+"Z";

      instrument = jsonNode["instrument"].toString().replaceAll(new RegExp("_"),"");
      time = lastCandle["time"] is DateTime ? lastCandle["time"] : DateTime.parse(lastTimeString);
      bid =double.parse( lastCandle["bid"]["c"].toString());
      ask = double.parse(lastCandle["ask"]["c"].toString());
  }

  setPrice(Map jsonNode)
  {
    instrument = jsonNode["instrument"].toString().replaceAll(new RegExp("_"),"");
    time = jsonNode["time"] is DateTime ? jsonNode["time"] : DateTime.parse(jsonNode["time"]);
    bid =double.parse( jsonNode["bid"].toString());
    ask = double.parse(jsonNode["ask"].toString());
  }
}