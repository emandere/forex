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
        "instrument":instrument,
        "time":time,
        "bid":bid,
        "ask":ask
      };
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

  setPrice(Map jsonNode)
  {
      instrument = jsonNode["instrument"].toString().replaceAll(new RegExp("_"),"");
      time = jsonNode["time"] is DateTime ? jsonNode["time"] : DateTime.parse(jsonNode["time"]);
      bid =jsonNode["bid"];
      ask = jsonNode["ask"];
  }
}