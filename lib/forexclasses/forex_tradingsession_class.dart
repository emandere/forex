part of forex_classes;
enum SessionType
{
  live,
  test
}
class TradingSession
{
  User sessionUser;
  DateTime startDate;
  DateTime endDate;
  DateTime currentTime;
  String lastUpdatedTime;
  SessionType sessionType;
  Strategy  strategy;
  String id;

  TradingSession()
  {
    sessionUser=new User();
    currentTime = DateTime.parse("2007-01-01T05:00Z");
    startDate = DateTime.parse("2007-01-01T05:00Z");
    sessionType=SessionType.test;
    strategy=new Strategy();
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
    sessionType=SessionType.values.
                  firstWhere((e) => e.toString() == (jsonMap["sessionType"]??"SessionType.test"),
                  orElse: () => SessionType.test);
    startDate=DateTime.parse(jsonMap["startDate"].toString());
    endDate=DateTime.parse(jsonMap.containsKey("endDate") && jsonMap["endDate"].toString() !="null"?jsonMap["endDate"].toString():"20300101");
    lastUpdatedTime=jsonMap.containsKey("lastUpdatedTime") && jsonMap["lastUpdatedTime"].toString()!="null"?jsonMap["lastUpdatedTime"].toString():"20010101";

    currentTime=DateTime.parse(jsonMap["currentTime"].toString());
    sessionUser = new User.fromJsonMap(jsonMap["sessionUser"]);
    strategy=jsonMap["strategy"]==null?new Strategy():new Strategy.fromJsonMap(jsonMap["strategy"]);
  }


  String toJson()
  {
    return JSON.encode(toJsonMap());
  }

  Map toJsonMap() {
    return {
      "_id":id,
      "id":id,
      "sessionType":sessionType.toString(),
      "startDate":startDate.toString(),
      "endDate":endDate.toString(),
      "lastUpdatedTime":lastUpdatedTime,
      "currentTime":currentTime.toString(),
      "strategy":strategy.toJsonMap(),
      "sessionUser":sessionUser.toJsonMap()
    };
  }

  updateUser(DateTime currentTime) async
  {

  }
  updateTime(var len,Function dailyValues,Function dailyValuesMissing)  async
  {
    currentTime=currentTime.add(new Duration(days: len));
    for(String pair in sessionUser.TradingPairs())
    {

      List<ForexDailyValue> val = await dailyValuesRange(pair,currentTime.toString(),dailyValues,dailyValuesMissing);
      if(val.length>0)
      {
        sessionUser.updateTrades(pair,currentTime.toString(),val[0].close);

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

  updateSessionPrice(Price currPrice)
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

  double adj(String pair)
  {
    double adj= (pair=="USDJPY") ? 0.01 : 1.0;
    return adj;
  }

  executeTradeStrategyPrice(String acc,Strategy currStrategy,Price currPrice)
  {
    if(sessionUser.Accounts[acc].MarginAvailable() * sessionUser.Accounts[acc].MarginRatio >
        (currPrice.bid * adj(currPrice.instrument)* currStrategy.units.toDouble()))
    {
      sessionUser.executeTradePriceStrategy(acc, currPrice, currStrategy);
      setStopLossAndTakeProfitTrade(acc,
          currStrategy.stopLoss*currPrice.bid,
          currStrategy.takeProfit*currPrice.bid);
    }
  }

  executeTradePrice(String acc,Price currPrice, int units,String position,double stopLoss,double takeProfit)
  {
    double adj(Price cP)
    {
      double adj= (cP.instrument =="USDJPY") ? 0.01 : 1.0;
      return adj;
    }
    if(sessionUser.Accounts[acc].MarginAvailable() * 50 > (currPrice.bid * adj(currPrice)  * units.toDouble()))
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

  setStopLossAndTakeProfitTrade(String acc,double stopLossPrice,double takeProfitPrice)
  {
    sessionUser.Accounts[acc].setTakeProfit(sessionUser.Accounts[acc].Trades.last, takeProfitPrice);
    sessionUser.Accounts[acc].setStopLoss(sessionUser.Accounts[acc].Trades.last, stopLossPrice);
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