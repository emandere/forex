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

class PostData
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

   }
   Map toJson()
   {
     return {"pair":pair,"units":units,"openDate":openDate,"closeDate":closeDate};
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
  List<Map<String,double>> balanceHistory;
  //List<Order> OpenOrder;
  //List<Order> ClosedOrder;
  //List balanceHistory;
  Account()
  {
    realizedPL=0.0;
    cash =0.0;
    Margin =0.0;
    MarginRatio=50.0;
    Trades = new List<Trade>();
    closedTrades = new List<Trade>();
    orders = new List<Order>();
    balanceHistory= new List<Map<String,double>> ();
    idcount=0;
  }

  AddHistory(String dt,double amount)
  {
     balanceHistory.add({"date":dt,"amount":amount});
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

    if(Trades.length>0)
    {
      Trade oppositeTrade = Trades.firstWhere(matchTrade, orElse: () => null);
      //int index = Trades.indexOf(oppositeTrade);
      if (oppositeTrade == null)
      {
        trade.id = idcount;
        Trades.add(trade);
        idcount++;
      }
      else
      {
        //print("removing");
        closeTrade(oppositeTrade.id);
      }
    }
    else
    {
      trade.id = idcount;
      Trades.add(trade);
      idcount++;
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
    cash=jsonNode["cash"];
    Trades=new List<Trade>();
    orders=new List<Order>();
    for(Map trade in jsonNode["Trades"])
    {
      Trades.add(new Trade.fromJsonMap(trade));
    }
    balanceHistory = jsonNode["balanceHistory"];
   /* for(Map day in jsonNode["balanceHistory"])
    {
      balanceHistory.add(day);
    }*/
  }

  Map toJson()
  {
    List<Map> MapTrades = new List<Map>();
    List<Map> MapOrders=new List<Map>();
    for(Trade trade in Trades)
    {
      MapTrades.add(trade.toJson());
    }

    for(Order order in orders)
    {
      MapOrders.add(order.toJson());
    }

    return {
      "id":id,
      "cash":cash,
      "realizedPL":realizedPL,
      "Trades":MapTrades,
      "balanceHistory":balanceHistory
    };
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


  printacc()
  {

    for(Trade currTrade in Trades)
    {
      print(currTrade.id.toString()+" "+ currTrade.pair+" "+currTrade.units.toString()+" "+currTrade.PL().toString());
    }
    print("PL "+UnrealizedPL().toString());
    print("Net Value "+NetAssetValue().toString());
    print("Margin Used "+MarginUsed().toString());
    print("Margin Available "+MarginAvailable().toString());
    print("Cash Balance "+cash.toString());
  }

  processOrders(Function dailyValuesRange,DateTime currentTime) async
  {
    for(Order order in orders)
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
            executeTrade(order.trade);
            order.expired = true;
          }
        }
      }
    }
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

  updateHistory(String dt)
  {
    primaryAccount.AddHistory(dt,primaryAccount.NetAssetValue());
    secondaryAccount.AddHistory(dt,primaryAccount.NetAssetValue());
  }

  fundAccount(String acc,double amount)
  {
    if(acc=="primary")
        primaryAccount.fundAccount(amount);
    else
        secondaryAccount.fundAccount(amount);
  }

  closeTrade(String acc,int index)
  {
    if(acc=="primary")
      primaryAccount.closeTrade(index);
    else
      secondaryAccount.closeTrade(index);
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
      primaryAccount.executeTrade(trade1);
    else
      secondaryAccount.executeTrade(trade1);

  }

  printacc()
  {
      print("Primary Account");
      primaryAccount.printacc();

      print("Secondary Account");
      secondaryAccount.printacc();

      print("User PL "+UnRealizedPL().toString());
      print("User Net Value "+NetAssetValue().toString());
      print("User Cash Balance "+Cash().toString());
  }

  processOrder(Function dailyValue,DateTime CurrentDate)
  {
      primaryAccount.processOrders(dailyValue,CurrentDate);
      secondaryAccount.processOrders(dailyValue,CurrentDate);
  }

  setOrder(String acc,int index,double price,bool direction)
  {
    if(acc=="primary")
      primaryAccount.setOrder(index,price,direction);
    else
      secondaryAccount.setOrder(index,price,direction);
  }

  transferAmount(String from,String to,double amount) {
    if (from == "primary")
    {
        primaryAccount.cash-=amount;
        secondaryAccount.cash+=amount;
    }
    else
    {
        secondaryAccount.cash-=amount;
        primaryAccount.cash+=amount;
    }
  }

}

class TradingSession
{
   User sessionUser;
   DateTime startDate;
   DateTime endDate;
   DateTime currentTime;
   //List<Map> lastDailyValue;
   //Function dailyValuesCall;
   //Function dailyValuesCallMissing;


   String id;

   TradingSession()
   {
     sessionUser=new User();
     currentTime = DateTime.parse("2007-01-01T05:00Z");
     startDate = DateTime.parse("2007-01-01T05:00Z");
     //dailyValuesCall = dailyValues;
     //dailyValuesCallMissing = dailyValuesMissing;

   }

   TradingSession.fromJSON(String json)
   {
     Map jsonNode = JSON.decode(json);
     setSession(jsonNode);
   }

   TradingSession.fromJSONMap(Map jsonNode)
   {
     setSession(jsonNode);
   }

   setSession(Map jsonMap)
   {
      id=jsonMap["id"];
      print("HEEEEEREEEE End "+jsonMap["endDate"].toString());
      startDate=DateTime.parse(jsonMap["startDate"].toString());
      //endDate=DateTime.parse(jsonMap["endDate"].toString());
      currentTime=DateTime.parse(jsonMap["currentTime"].toString());
      sessionUser = new User.fromJsonMap(jsonMap["sessionUser"]);
      print("HEEEEEREEEE COMPLETE "+jsonMap["currentTime"].toString());
   }


   String toJson()
   {
     return JSON.encode(toJsonMap());
   }

   Map toJsonMap() {
      return {
        "_id":id,
       "id":id,
       "startDate":startDate.toString(),
       "endDate":endDate.toString(),
       "currentTime":currentTime.toString(),
       "sessionUser":sessionUser.toJsonMap()
       };
   }

   updateUser(DateTime currentTime) async
   {

   }
   updateTime(var len,Function dailyValues,Function dailyValuesMissing)  async
   {
     currentTime=currentTime.add(new Duration(days: len));
     //print(currentTime.toString());
     for(String pair in sessionUser.TradingPairs())
     {
       //print(pair);
       List<ForexDailyValue> val = await dailyValuesRange(pair,currentTime.toString(),dailyValues,dailyValuesMissing);
       if(val.length>0)
       {
         sessionUser.updateTrades(pair,currentTime.toString(),val[0].close);
         //print(val[0].close.toString());
       }
     }
   }


   Future <List<ForexDailyValue>> dailyValuesRange(String pair,String startDate,Function dailyValuesCall,Function dailyValuesCallMissing) async
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
     List<Map> data= await dailyValuesCall(pair,DateTime.parse(startDate));
     if(data.length==0)
     {
       await dailyValuesCallMissing(pair,DateTime.parse(startDate));
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
       sessionUser.closeTrade(acc,index);
   }

   fundAccount(String acc,double amount)
   {
      sessionUser.fundAccount(acc,amount);
   }

   executeTrade(String acc,String pair, int units,String position,String openDate)
   {
      sessionUser.executeTrade(acc,pair,units,position,openDate);
   }

   processOrders() async
   {
      sessionUser.processOrder(dailyValuesRange,currentTime);
   }

   setOrder(String acc,int index,double price,bool direction)
   {
        sessionUser.setOrder(acc,index,price,direction);
   }

   transferAmount(String from,String to,double amount)
   {
        sessionUser.transferAmount(from,to,amount);
   }

   updateHistory()
   {
     sessionUser.updateHistory(currentTime.toString());
   }

   List<Trade> openTrades(String account)
   {
     if(account=="primary")
      return sessionUser.primaryAccount.Trades;
     else
       return sessionUser.secondaryAccount.Trades;
   }

}



