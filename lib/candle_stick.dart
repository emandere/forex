class ForexDailyValue
{
  String pair;
  String date;
  double open;
  double high;
  double low;
  double close;
  String time;
  ForexDailyValue();
  ForexDailyValue.fromData(this.pair,this.date,this.open,this.high,this.low,this.close);
  ForexDailyValue.fromString(String line,{String pairName})
  {
    print(line);
    List<String> vals = line.split(",");

    pair = pairName;

    if(vals[0].contains("-"))
      date =vals[0];
    else
      date = vals[0].substring(0,4)+"-"+vals[0].substring(4,6)+"-"+vals[0].substring(6,8);


    open = double.parse(vals[1]);
    high = double.parse(vals[2]);
    low  = double.parse(vals[3]);
    close= double.parse(vals[4]);

  }
  ForexDailyValue.fromJson(Map json)
  {
    //Map jsonvalue = JSON.decode(json);
    if(json["pair"]!=null)
      pair=json["pair"];

    if(json["date"].contains("-"))
      date =json["date"];
    else
      date = json["date"].substring(0,4)+"-"+json["date"].substring(4,6)+"-"+json["date"].substring(6,8);//json["date"];

    open = json["open"];//double.parse(json["open"]);
    high = json["high"];//double.parse(json["high"]);
    low  = json["low"];//double.parse(json["low"]);
    close= json["close"];//double.parse(json["close"]);
    time=json["time"];
  }

   Map toJsonMap()
   {
      return{"pair":pair,"date":date,"open":open,"high":high,"low":low,"close":close};
   }
}


class ForexMinuteValue
{
  String pair;
  String date;
  String time;
  double open;
  double high;
  double low;
  double close;
  ForexMinuteValue();
  ForexMinuteValue.fromData(this.pair,this.date,this.time,this.open,this.high,this.low,this.close);
  ForexMinuteValue.fromString(String line,{String pairName})
  {

    List<String> vals = line.split(",");
    if(pairName!=null)
      pair=vals[0];

    if(vals[1].contains("-"))
      date =vals[1];
    else
      date = vals[1].substring(0,4)+"-"+vals[1].substring(4,6)+"-"+vals[1].substring(6,8);

    time = vals[2];
    open = double.parse(vals[3]);
    high = double.parse(vals[4]);
    low  = double.parse(vals[5]);
    close= double.parse(vals[6]);
  }
  ForexMinuteValue.fromJson(Map json)
  {
    //Map jsonvalue = JSON.decode(json);
    if(json["pair"]!=null)
      pair=json["pair"];

    if(json["date"].contains("-"))
      date =json["date"];
    else
      date = json["date"].substring(0,4)+"-"+json["date"].substring(4,6)+"-"+json["date"].substring(6,8);//json["date"];
    time=json["time"];
    open = json["open"];//double.parse(json["open"]);
    high = json["high"];//double.parse(json["high"]);
    low  = json["low"];//double.parse(json["low"]);
    close= json["close"];//double.parse(json["close"]);
  }

  Map toJsonMap()
  {
    return{"pair":pair,"date":date,"time":time,"open":open,"high":high,"low":low,"close":close};
  }
}

