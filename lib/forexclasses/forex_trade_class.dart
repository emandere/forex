part of forex_classes;
class Trade
{
  String pair;
  int units;
  int id;
  String openDate;
  String closeDate;
  double openPrice;
  double closePrice;
  double stopLoss;
  double takeProfit;
  bool long;
  bool init;
  Position()
  {
    if(long)
      return 1.0;
    else
      return -1.0;
  }
  Trade()
  {
    init=true;
    long=false;
    openPrice=0.0;
    closePrice=0.0;
  }
  double value()
  {

    return units * closePrice*adj();
  }

  double adj()
  {
    double adj= (pair=="USDJPY") ? 0.01 : 1.0;
    return adj;
  }
  double PL()
  {
    return units * Position() * (closePrice - openPrice)*adj();
  }
  Trade.fromJsonMap(Map jsonNode)
  {
    setTrade(jsonNode);
  }

  setTrade(jsonNode)
  {
    pair=jsonNode["pair"];
    units=jsonNode["units"];
    openDate=jsonNode["openDate"];
    closeDate=jsonNode["closeDate"];
    init=jsonNode["init"];
    long= jsonNode["long"].toString().toLowerCase()=="true";
    openPrice=double.parse(jsonNode["openPrice"].toString());
    closePrice=double.parse(jsonNode["closePrice"].toString());
    id=int.parse(jsonNode["id"].toString());
  }
  Map toJson()
  {
    return { "pair":pair,
      "units":units,
      "openDate":openDate,
      "closeDate":closeDate,
      "long":long,
      "openPrice":openPrice,
      "closePrice":closePrice,
      "id":id,
      "init":init
    };
  }

  updateTrade(String dt,price)
  {
    if(init)
    {
      openPrice=price;
      init=false;
    }
    closeDate=dt;
    closePrice=price;
  }
}