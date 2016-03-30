library forex_classes;
import 'dart:convert';
import 'dart:async';
import 'candle_stick.dart';


class UserData
{
  String data;
  Map toJsonMap()
  {
    return {"data":data};
  }

  String toJson()
  {
     return JSON.encode(toJsonMap());
  }
}


class Trade
{
   String pair;
   int units;
   int id;
   String openDate;
   String closeDate;
   double openPrice;
   double closePrice;
   bool long;
   Position()
   {
      if(long)
        return 1.0;
      else
        return -1.0;
   }
   Trade()
   {
      long=false;
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

   }
   Map toJson()
   {
     return {"pair":pair,"units":units,"openDate":openDate,"closeDate":closeDate};
   }

   updateTrade(String dt,price)
   {
     if(openPrice==null)
     {
        openPrice=price;
     }
     closeDate=dt;
     closePrice=price;
   }
}

class Order
{
    Trade trade;
    String expirationDate;
    double triggerprice;
    bool expired;
    bool above;

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

class Account
{
  String id;
  String _id;
  double cash;
  double realizedPL;
  double Margin;
  double MarginRatio;
  int idcount;
  List<Trade> Trades;
  List<Trade> closedTrades;
  List<Order> orders;

  //List<Order> OpenOrder;
  //List<Order> ClosedOrder;
  Account()
  {
    realizedPL=0.0;
    cash =0.0;
    Margin =0.0;
    MarginRatio=50.0;
    Trades = new List<Trade>();
    closedTrades = new List<Trade>();
    orders = new List<Order>();
    idcount=0;
  }

  fundAccount(double amount)
  {
    cash+=amount;
  }

  closeTrade(int index)
  {
     Trade moveTrade = Trades.firstWhere((Trade i)=>i.id==index);//Trades[index];
     int tradeIndex = Trades.indexOf(moveTrade);
     realizedPL+=moveTrade.PL();
     cash+=moveTrade.PL();
     closedTrades.add(moveTrade);
     Trades.removeAt(tradeIndex);
  }

  Account.fromJsonMap(Map jsonNode)
  {
    setAccount(jsonNode);
  }

  executeTrade(Trade trade)
  {
    //balance = balance - (trade.units * trade.openPrice);
    bool matchTrade(Trade i)
    {
        if(i.pair==trade.pair && i.units==trade.units && (i.long!=trade.long))
          return true;
        else
          return false;

    }

    Trade oppositeTrade=Trades.firstWhere(matchTrade,orElse: () => null);
    int index = Trades.indexOf(oppositeTrade);
    if(oppositeTrade==null)
    {
      trade.id=idcount;
      Trades.add(trade);
      idcount++;
    }
    else
    {
      //print("removing");
      closeTrade(index);
    }

  }

  setOrder(int index,double price,direction)
  {
      Trade stopTrade = new Trade();
      Trade trade = Trades.firstWhere((Trade i)=>i.id==index);
      if(trade!=null)
      {
        stopTrade.pair = trade.pair;
        stopTrade.units = trade.units;
        stopTrade.long = !trade.long;

        Order stopLossOrder = new Order(stopTrade,price,direction);
        orders.add(stopLossOrder);
      }
  }

  setAccount(jsonNode)
  {
    id=jsonNode["id"];
    realizedPL=jsonNode["realizedPL"];
    Trades=new List<Trade>();
    for(Map trade in jsonNode["Trades"])
    {
      Trades.add(new Trade.fromJsonMap(trade));
    }
  }

  Map toJson()
  {
    List<Map> MapTrades = new List<Map>();
    for(Trade trade in Trades)
    {
      MapTrades.add(trade.toJson());
    }
    return {"id":id,"realizedPL":realizedPL,"Trades":MapTrades};
  }
  num RealizedPL()
  {
   /* double tradeAmount=0.0;
    for(Trade currTrade in Trades)
    {
       tradeAmount += (currTrade.units * currTrade.closePrice);
    }*/

    return realizedPL;
  }

  num UnrealizedPL()
  {
    double tradeAmount=0.0;
    for(Trade currTrade in Trades)
    {
      tradeAmount += currTrade.PL();
    }
    return tradeAmount;
  }

  num NetAssetValue()
  {
      return cash + UnrealizedPL();
  }

  num MarginUsed()
  {
    double margin=0.0;
    for(Trade currTrade in Trades)
    {
      margin += currTrade.value()/MarginRatio;
    }
    return margin;
  }

  num MarginAvailable()
  {
    return NetAssetValue() - MarginUsed();
  }

  void Deposit(num amt)
  {

  }

  void WithDraw(num amt)
  {

  }


}
class User
{

  String id;


  String status;
  Map<String,Account> Accounts;
  User()
  {
    Accounts=new Map<String,Account>();
    Accounts["primary"]=new Account();
    Accounts["primary"].id="primary";

    Accounts["secondary"]=new Account();
    Accounts["secondary"].id="secondary";
  }
  Account get primaryAccount => Accounts["primary"];
  Account get secondaryAccount => Accounts["secondary"];
  User.fromJson(String json)
  {
    Map jsonNode = JSON.decode(json);
    setUser(jsonNode);
  }

  User.fromJsonMap(Map jsonNode)
  {
    setUser(jsonNode);
  }

  setUser(Map jsonNode)
  {
    id = jsonNode["id"];
    status = jsonNode["status"];

    Accounts = new Map<String,Account>();
    Accounts["primary"]=new Account.fromJsonMap(jsonNode["Accounts"]["primary"]);
    Accounts["secondary"]=new Account.fromJsonMap(jsonNode["Accounts"]["secondary"]);
   /* for(Map acc in jsonNode["Accounts"])
    {
       Accounts.add(new Account.fromJsonMap(acc));
    }*/
    //Accounts=jsonNode["Accounts"];
  }

  String toJson()
  {
    return JSON.encode(toJsonMap());
  }

  Map toJsonMap()
  {
    Map MapAccounts = new Map();

    MapAccounts["primary"]=Accounts["primary"].toJson();
    MapAccounts["secondary"]=Accounts["secondary"].toJson();
    return {"_id":id,"id":id,"status":status,"Accounts":MapAccounts};
  }
  num RealizedPL()
  {
    num balance =0;
    //for(Account acct in Accounts)
    //{
      balance=primaryAccount.RealizedPL()+ secondaryAccount.RealizedPL();
    //}

    return balance;
  }

  num UnRealizedPL()
  {
    num balance =0;
    //for(Account acct in Accounts)
    //{
    balance=primaryAccount.UnrealizedPL()+ secondaryAccount.UnrealizedPL();
    //}

    return balance;
  }

  num Cash()
  {
    return primaryAccount.cash + secondaryAccount.cash;
  }

  num MarginUsed()
  {
    return primaryAccount.MarginUsed()+secondaryAccount.MarginUsed();
  }

  num MarginAvailable()
  {
    return primaryAccount.MarginAvailable()+secondaryAccount.MarginAvailable();
  }

  num NetAssetValue()
  {
    num balance =0;

    balance=primaryAccount.NetAssetValue()+secondaryAccount.NetAssetValue();

    return balance;
  }

  List<String> TradingPairs()
  {
     List<String> pairs= new List<String>();
     //List<Trade> allTrades = new List<Trade>.from(primaryAccount.Trades)..addAll(primaryAccount.Trades);
     for(Trade currTrade in new List<Trade>.from(primaryAccount.Trades)..addAll(secondaryAccount.Trades))
     {
        if(!pairs.contains(currTrade.pair))
        {
          pairs.add(currTrade.pair);
        }
     }
     return pairs;
  }

  updateTrades(String pair,String dt,double price)
  {
    for(Trade currTrade in new List<Trade>.from(primaryAccount.Trades)..addAll(secondaryAccount.Trades))
    {
      if(currTrade.pair==pair)
      {
          currTrade.updateTrade(dt,price);
      }
    }
  }

  printacc()
  {

    for(Trade currTrade in new List<Trade>.from(primaryAccount.Trades)..addAll(secondaryAccount.Trades))
    {
        print(currTrade.id.toString()+" "+ currTrade.pair+" "+currTrade.units.toString()+" "+currTrade.PL().toString());
    }
    print("PL "+UnRealizedPL().toString());
    print("Net Value "+NetAssetValue().toString());
    print("Margin Used "+MarginUsed().toString());
    print("Margin Available "+MarginAvailable().toString());
    print("Cash Balance "+Cash().toString());
  }
}

class TradingSession
{
   User sessionUser;
   DateTime startDate;
   DateTime endDate;
   DateTime currentTime;
   var dailyValuesCall;
   var dailyValuesCallMissing;

   TradingSession(var dailyValues,var dailyValuesMissing)
   {
     sessionUser=new User();
     currentTime = DateTime.parse("2007-01-01T05:00Z");
     dailyValuesCall = dailyValues;
     dailyValuesCallMissing = dailyValuesMissing;

   }


   updateUser(DateTime currentTime) async
   {

   }

   updateTime(var len)  async
   {
     currentTime=currentTime.add(new Duration(days: len));
     //print(currentTime.toString());
     for(String pair in sessionUser.TradingPairs())
     {
       //print(pair);
       List<ForexDailyValue> val = await dailyValuesRange(pair,currentTime.toString(),currentTime.toString());
       if(val.length>0)
       {
         sessionUser.updateTrades(pair,currentTime.toString(),val[0].close);
         //print(val[0].close.toString());
       }
     }
   }


   Future <List<ForexDailyValue>> dailyValuesRange(String pair,String startDate,String endDate) async
   {
     List<ForexDailyValue> dailyvals=new List<ForexDailyValue>();

     sendDailyValues(mapValues)
     {
       for (Map mapDaily in mapValues)
       {
         ForexDailyValue val = new ForexDailyValue.fromJson(mapDaily);
         dailyvals.add(val);
       }
       return dailyvals;
     }
     List<Map> data = await dailyValuesCall(pair,DateTime.parse(startDate),DateTime.parse(endDate));
     if(data.length==0)
     {
       //print("used missing");
       data = await dailyValuesCallMissing(pair,DateTime.parse(startDate),DateTime.parse(endDate));
       return sendDailyValues(data.reversed.toList());
     }
     else
     {
       return sendDailyValues(data);
     }
   }

   printacc()
   {
      sessionUser.printacc();
   }

   closeTrade(String acc,int index)
   {
     if(acc=="primary")
       sessionUser.primaryAccount.closeTrade(index);
     else
       sessionUser.secondaryAccount.closeTrade(index);
   }

   executeTrade(String acc,String pair, int units,String position,String openDate)
   {
     Trade trade1 = new Trade();
     trade1.pair=pair;
     trade1.units=units;
     trade1.openDate=openDate;

     if(position=="long")
       trade1.long=true;
     else
        trade1.long=false;

     if(acc=="primary")
       sessionUser.primaryAccount.executeTrade(trade1);
     else
       sessionUser.secondaryAccount.executeTrade(trade1);

   }

   processOrders() async
   {
      for(Order order in sessionUser.primaryAccount.orders)
      {
        if(!order.expired)
        {
          List<ForexDailyValue> val = await dailyValuesRange(order.trade.pair, currentTime.toString(), currentTime.toString());
          if (val.length > 0)
          {
            print("processed " + val[0].close.toString()+" "+order.trade.long.toString() );
            if(order.checkTrigger(val[0].close))
            {
              print("processed event");
              sessionUser.primaryAccount.executeTrade(order.trade);
              order.expired = true;
            }
            /*if ((val[0].close > order.triggerprice) && order.long)
            {
              sessionUser.primaryAccount.executeTrade(order.trade);
              order.expired = true;
            }*/

            /*if ((val[0].close < order.triggerprice))// && order.long==false)
            {
              print("processed event");
              //sessionUser.primaryAccount.executeTrade(order.trade);
              order.expired = true;*/
          }
        }
      }
   }

   setOrder(int index,double price,bool direction)
   {
        sessionUser.primaryAccount.setOrder(index,price,direction);
   }

}


