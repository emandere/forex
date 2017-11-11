part of forex_classes;
class Order
{
  Trade trade;
  String expirationDate;
  double triggerprice;
  bool expired;
  bool above;


  Map toJson()
  {
    return
      {
        "expirationDate":expirationDate,
        "triggerprice":triggerprice,
        "expired":expired,
        "above":above,
        "trade":trade.toJson()
      };
  }

  Order.fromJsonMap(Map jsonNode)
  {
    setOrder(jsonNode);
  }

  setOrder(jsonNode)
  {
    expirationDate=jsonNode["expirationDate"];
    triggerprice=double.parse(jsonNode["triggerprice"].toString());
    expired=jsonNode["expired"];
    above=jsonNode["above"];
    trade=new Trade.fromJsonMap(jsonNode["trade"]);
  }

  Order(Trade t,double price,bool abovebelow)
  {
    trade = t;
    triggerprice=price;
    expired=false;
    above=abovebelow;
  }
  bool checkTrigger(double price)
  {
    if(above)
    {
      if(price>=triggerprice)
        return true;
      else
        return false;
    }
    else
    {
      if(price<=triggerprice)
        return true;
      else
        return false;
    }
  }

}