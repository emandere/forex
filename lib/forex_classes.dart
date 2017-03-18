library forex_classes;
import 'dart:convert';
import 'dart:async';
import 'candle_stick.dart';
import 'forex_stats.dart';
import 'dart:collection';
import "package:collection/collection.dart";

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
              "id":id
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
        if(i.pair==trade.pair && i.units==trade.units && i.openDate==trade.openDate && (i.long!=trade.long))
          return true;
        else
          return false;

    }

    if(Trades.isNotEmpty)
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

  setOrder(int index,String openDate,double price,direction)
  {
      Trade stopTrade = new Trade();
      Trade trade = Trades.firstWhere((Trade i)=>i.id==index,orElse: () => null);
      if(trade!=null)
      {
        stopTrade.pair = trade.pair;
        stopTrade.units = trade.units;
        stopTrade.long = !trade.long;
        stopTrade.openDate = openDate;

        Order stopLossOrder = new Order(stopTrade,price,direction);
        orders.add(stopLossOrder);
      }
      else
      {
         print("order failed");
      }
  }

  setAccount(jsonNode)
  {

    id=jsonNode["id"];
    realizedPL=double.parse(jsonNode["realizedPL"].toString());
    cash=double.parse(jsonNode["cash"].toString());
    idcount=jsonNode["idcount"];
    Trades=new List<Trade>();
    closedTrades = new List<Trade>();
    orders=new List<Order>();
    for(Map trade in jsonNode["Trades"])
    {
      Trades.add(new Trade.fromJsonMap(trade));
    }

    for(Map trade in jsonNode["closedTrades"])
    {
      closedTrades.add(new Trade.fromJsonMap(trade));
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
    List<Map> MapClosedTrades = new List<Map>();
    List<Map> MapOrders=new List<Map>();
    for(Trade trade in Trades)
    {
      MapTrades.add(trade.toJson());
    }

    for(Trade trade in closedTrades)
    {
      MapClosedTrades.add(trade.toJson());
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
      "closedTrades":MapClosedTrades,
      "balanceHistory":balanceHistory,
      "idcount":idcount
    };
  }
  num RealizedPL()
  {
    double tradeAmount=0.0;
    for(Trade closedTrade in closedTrades)
    {
      tradeAmount += closedTrade.PL();
    }
    return tradeAmount;
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

  num PL()
  {
     return RealizedPL() + UnrealizedPL();
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

  double averageTradePL()
  {
     if(closedTrades.isNotEmpty)
     {
       var PLList = closedTrades.map((x) => x.PL()).toList();
       return Average(PLList);
     }
     else
     {
       return 0.0;
     }
  }

  double stdDevTradePL()
  {
    if(closedTrades.isNotEmpty)
    {
      var PLList = closedTrades.map((x) => x.PL()).toList();
      return StdDev(PLList);
    }
    else
    {
      return 0.0;
    }
  }


  printacc()
  {

    for(Trade currTrade in Trades)
    {
      print(currTrade.id.toString()+" "+ currTrade.pair+" "+currTrade.units.toString()+" "+currTrade.PL().toString());
    }
    print("PL "+PL().toString());
    print("Net Value "+NetAssetValue().toString());
    print("Margin Used "+MarginUsed().toString());
    print("Margin Available "+MarginAvailable().toString());
    print("Cash Balance "+cash.toString());
    print("Average Realized PL "+averageTradePL().toString());
    print("Std Dev Realized PL "+stdDevTradePL().toString());
    printAverageClosedTradeByPair();
  }

  printAverageClosedTradeByPair()
  {
    selectByName(String pair)=>closedTrades
        .where((trade)=>trade.pair==pair)
        .map((trade)=>trade.PL());

    var pairs = closedTrades.map((trade)=>trade.pair)
                            .toSet();

    var averageByPair = pairs.map(selectByName)
                               .map(Average);

    var averageByPairListZip = new IterableZip([pairs,averageByPair]);

    averageByPairListZip.forEach(print);

  }

  processOrders(Function dailyValuesRange,Function dailyValues,Function dailyValuesMissing,DateTime currentTime) async
  {
    for(Order order in orders)
    {
      if(!order.expired)
      {
        List<ForexDailyValue> val = await dailyValuesRange(order.trade.pair, currentTime.toString(),dailyValues,dailyValuesMissing);
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

  processOrdersNew(String pair,double currentValue)
  {
    for(Order order in orders)
    {
      if(!order.expired)
      {
          if(order.trade.pair==pair && order.checkTrigger(currentValue))
          {
            //print("processed start event " +order.trade.pair +" "+order.trade.openDate+" "+Trades.length.toString());
            executeTrade(order.trade);
            //print("processed end event " +order.trade.pair +" "+order.trade.openDate+" "+Trades.length.toString());
            order.expired = true;
            var twinOrder = orders.firstWhere((x)=>x.trade.pair==order.trade.pair
                                               && x.above!=order.above
                                               && x.trade.openDate==order.trade.openDate);
            twinOrder.expired=true;
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

  num PL()
  {
     return UnRealizedPL() + RealizedPL();
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

  List<Trade> closedTrades()
  {
     return new List<Trade>.from(primaryAccount.closedTrades)..addAll(secondaryAccount.closedTrades);
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

  executeTrade(String acc,String pair, int units,String position,String openDate,double stopLoss,double takeProfit)
  {
    Trade trade1 = new Trade();
    trade1.pair=pair;
    trade1.units=units;
    trade1.openDate=openDate;
    trade1.closeDate=openDate;
    trade1.stopLoss=stopLoss;
    trade1.takeProfit=takeProfit;
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

      print("User PL "+PL().toString());
      print("User Net Value "+NetAssetValue().toString());
      print("User Cash Balance "+Cash().toString());
  }

  processOrder(Function dailyValue,Function dailyValues,Function dailyValuesMissing,DateTime CurrentDate)
  {
      primaryAccount.processOrders(dailyValue,dailyValues,dailyValuesMissing,CurrentDate);
      secondaryAccount.processOrders(dailyValue,dailyValues,dailyValuesMissing,CurrentDate);
  }

  processOrdersNew(String pair,double currentValue)
  {
      primaryAccount.processOrdersNew(pair,currentValue);
      secondaryAccount.processOrdersNew(pair,currentValue);
  }
  setOrder(String acc,String openDate,int index,double price,bool direction)
  {
    if(acc=="primary")
      primaryAccount.setOrder(index,openDate,price,direction);
    else
      secondaryAccount.setOrder(index,openDate,price,direction);
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

      print("id= "+id);
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

   updateSession(List<Map> pairs)
   {
     String currTime = pairs.first['date'];
     currentTime = DateTime.parse(currTime);
     for(String pair in sessionUser.TradingPairs())
     {
        var pairMap = pairs.firstWhere((x)=>x["pair"]==pair);
        sessionUser.updateTrades(pair,currTime,pairMap["close"]);
        sessionUser.processOrdersNew(pair,pairMap["close"]);
     }
     updateHistory();

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

   executeTrade(String acc,String pair, int units,String position,String openDate,double price,double stopLoss,double takeProfit)
   {
      if(sessionUser.Accounts[acc].MarginAvailable() * 50 > (price * units.toDouble()))
      {
        sessionUser.executeTrade(acc, pair, units,position, openDate, stopLoss, takeProfit);
        setStopLossAndTakeProfit(acc, openDate, position, stopLoss, takeProfit);
      }
   }

   setStopLossAndTakeProfit(String account,String openDate,String position,double stopLossPrice,double takeProfitPrice)
   {
     //int lastTrade = sessionUser.Accounts[account].idcount-1;
     if(sessionUser.Accounts[account].Trades.isEmpty)
        print ("here!");
     int lastTrade = sessionUser.Accounts[account].Trades.last.id;
     //window.alert(lastTrade.toString()+" "+currentSession.sessionUser.Accounts[account.value].Trades[0].id.toString());
     if(position=="long")
     {
       setOrder(account,openDate,lastTrade,stopLossPrice,false);
       setOrder(account,openDate,lastTrade,takeProfitPrice,true);
       //window.alert(currentSession.sessionUser.Accounts[account.value].orders.length.toString());
     }
     else
     {
       setOrder(account,openDate,lastTrade,stopLossPrice,true);
       setOrder(account,openDate,lastTrade,takeProfitPrice,false);
     }
   }

   processOrders(Function dailyValues,Function dailyValuesMissing) async
   {
      sessionUser.processOrder(dailyValuesRange,dailyValues,dailyValuesMissing,currentTime);
   }

   processOrdersNew(String pair,double currentValue)
   {
      sessionUser.processOrdersNew(pair,currentValue);
   }

   setOrder(String acc,String openDate,int index,double price,bool direction)
   {
        sessionUser.setOrder(acc,openDate,index,price,direction);
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

   double balance()
   {
      return sessionUser.primaryAccount.NetAssetValue()+sessionUser.secondaryAccount.NetAssetValue();
   }

   double PL()
   {
     return sessionUser.primaryAccount.UnrealizedPL() + sessionUser.primaryAccount.RealizedPL() ;
   }

}



