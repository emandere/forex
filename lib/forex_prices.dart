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

  Price.fromJsonDailyValue(Map dailyPairValue)
  {
      instrument=dailyPairValue["pair"];
      bid=dailyPairValue["close"];
      ask=dailyPairValue["close"];
      time=dailyPairValue["datetime"];
  }

  setPrice(Map jsonNode)
  {
      instrument = jsonNode["instrument"].toString().replaceAll(new RegExp("_"),"");
      time = jsonNode["time"] is DateTime ? jsonNode["time"] : DateTime.parse(jsonNode["time"]);
      bid =double.parse( jsonNode["bid"].toString());
      ask = double.parse(jsonNode["ask"].toString());
  }
}