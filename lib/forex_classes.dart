library forex_classes;
import 'dart:convert';
import 'dart:async';
import 'candle_stick.dart';
import 'forex_stats.dart';
import 'dart:collection';
import "package:collection/collection.dart";
import 'forex_prices.dart';
import 'dart:convert';
import 'forex_indicator_rules.dart';
part 'forexclasses/forex_trade_class.dart';
part 'forexclasses/forex_strategy_class.dart';
part 'forexclasses/forex_order_class.dart';
part 'forexclasses/forex_account_class.dart';
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

  updateTradesPrice(Price currPrice)
  {
    List<Trade> allTrades = new List<Trade>.from(primaryAccount.Trades)..addAll(secondaryAccount.Trades);
    List<Trade> selectedTrades = allTrades.where((trade)=>trade.pair==currPrice.instrument).toList();
    for(Trade currTrade in selectedTrades)
    {
        currTrade.updateTrade(currPrice.time.toIso8601String(), currPrice.bid);
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



  processOrdersNew(String pair,double currentValue)
  {
      primaryAccount.processOrdersNew(pair,currentValue);
      secondaryAccount.processOrdersNew(pair,currentValue);
  }

  processOrdersNewPrice(Price currPrice)
  {
    primaryAccount.processOrdersNew(currPrice.instrument,currPrice.bid);
    secondaryAccount.processOrdersNew(currPrice.instrument,currPrice.bid);
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

   upsateSessioPrice(Price currPrice)
   {
     currentTime =currPrice.time;
     sessionUser.updateTradesPrice(currPrice);
     sessionUser.processOrdersNew(currPrice.instrument,currPrice.bid);
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

   executeTradePrice(String acc,Price currPrice, int units,String position,double stopLoss,double takeProfit)
   {
     if(sessionUser.Accounts[acc].MarginAvailable() * 50 > (currPrice.bid  * units.toDouble()))
     {
       sessionUser.executeTrade(acc, currPrice.instrument, units,position, currPrice.time.toIso8601String(), stopLoss, takeProfit);
       setStopLossAndTakeProfit(acc, currPrice.time.toIso8601String(), position, stopLoss, takeProfit);
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



