
import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:rpc/rpc.dart';
import 'package:intl/intl.dart';
import 'candle_stick.dart';
import 'forex_prices.dart';
import 'forex_classes.dart';
import 'forex_mongo.dart';
import 'forex_indicator_rules.dart';


@ApiClass(
    name: 'forexclasses',  // Optional (default is 'cloud' since class name is Cloud).
    version: 'v1'
)



class ForexClasses
{
  var db;
  var mongoCurrencyPairs;
  ForexMongo mongoLayer;
  ForexClasses(this.mongoLayer)
  {

  }

  @ApiMethod(path: 'getsession/{sessionid}')
  Future<TradingSession> readSession(String sessionid)
  {
    getSessionString(result)
    {
      TradingSession sessionRead = new TradingSession.fromJSONMap(result);
      //List<String> lstuser=new List<String>();
      //lstuser.add(userRead.toJson());
      return sessionRead;
    }
    return mongoLayer.readSession(sessionid).then(getSessionString);
  }

  @ApiMethod(path: 'getlatestsession/{sessionid}/{lastUpdate}')
  Future<List<TradingSession>> readLatestSession(String sessionid,String lastUpdate) async
  {
     Map MapSession = await mongoLayer.getLatestSession(sessionid, DateTime.parse(lastUpdate));

     if(MapSession==null)
     {
         return [];
     }
     else
     {
         return [new TradingSession.fromJSONMap(MapSession)];
     }

  }

  @ApiMethod(path: 'deletesession/{sessionid}')
  Future<List<String>> deleteSession(String sessionid) async
  {

    await mongoLayer.deleteSession(sessionid);
    return ["passed"];
  }

  @ApiMethod(path: 'pairs')
  Future<List<String>> readMongoPairs()
  {
    return mongoLayer.readMongoPairs();
  }

  @ApiMethod(path: 'rules')
  Future<List<String>> readRules() async
  {
    return rules();
  }

  @ApiMethod(path: 'starttime')
  Future<Map<String,DateTime>> getStartTime() async
  {
    var x = await mongoLayer.getStartTime();
    return {"time":x["time"]};
  }



  @ApiMethod(path: 'sessions')
  Future<List<TradingSession>> getSessions() async
  {
    List<TradingSession> sessions=new List<TradingSession>();
    await for (Map sessionMap in mongoLayer.getSessions())
    {
      TradingSession session = new TradingSession.fromJSONMap(sessionMap);
      sessions.add(session);
    }
    return sessions;
  }

  @ApiMethod(path: 'countsessions')
  Future<List<int>> getCountSessions() async
  {
      return [await mongoLayer.countSessions()];
  }



  @ApiMethod(path: 'usernames')
  Future<List<String>> readUserNames()
  {
    return mongoLayer.readUserNames();
  }
  /*closedb(var dummy)
  {
    db.close();
    return testpairs;
  }*/
  updateCurrencyMongo(var dummy)
  {
    //print("Helpp");

    List<String> testpairs=new List<String>();
    closedb(var dummy)
    {
      db.close();
      return testpairs;
    }
    return db.collection('currencypairs').find().forEach(
            (pair)
        {
          testpairs.add(pair["name"]);
        }
    ).then(closedb);

  }


  @ApiMethod(path: 'addUser/{name}')
  Future<List<String>> addUser(String name)
  {

    showMongoUser(var result)
    {

      List<String> testuser=new List<String>();
      return db.collection('user').find(where.eq('id',name)).forEach(
              (user)
          {
            testuser.add(user['id']);

          }).then((dummy){return testuser;});
      //return "Success";
    }

    mongoAddUser(var result)
    {
      User user = new User();
      user.id=name;
      return db.collection('user').insert(user.toJson());
    }
    db = new Db("mongodb://localhost/testdb");
    return db.open().then(mongoAddUser).then(showMongoUser);//.then(closedb);

  }

  @ApiMethod(method: 'POST',path: 'addsessionpost')
  Future<List<String>> addSessionPost(PostData sessionData) async
  {
    List<String> success = new List<String>();
    success.add("pass");
    TradingSession session=new TradingSession.fromJSON(sessionData.data);
    //await mongoLayer.saveSession(session);
    await mongoLayer.pushTradingSession(session);
    return success;
  }


  @ApiMethod(method: 'POST',path: 'pushtoqueuesessionpost')
  Future<List<String>> pushtoqueueSessionPost(PostData sessionData) async
  {
    List<String> success = new List<String>();
    success.add("pass");
    TradingSession session=new TradingSession.fromJSON(sessionData.data);
    await mongoLayer.pushTradingSession(session);
    return success;
  }


  /*@ApiMethod(method: 'POST',path: 'adduserpost')
  Future<List<String>> addUserPost(UserData fuser)
  {
    User user = new User.fromJson(fuser.data);
    return mongoLayer.addUser(user);
  }*/

  @ApiMethod(path:'getuser/{username}')
  Future<List<User>> getUser(String username)
  {
     getUserString(result)
     {
        User userRead = new User.fromJsonMap(result);
        //List<String> lstuser=new List<String>();
        //lstuser.add(userRead.toJson());
        return [userRead];
     }
     return mongoLayer.getUser(username).then(getUserString);
  }

  /*@ApiMethod(method: 'POST',path: 'removeuser')
  Future<List<String>> removeUser(UserData userid)
  {
     return mongoLayer.removeUserById(userid.data);
  }*/

  @ApiMethod(path: 'dailyvalues/{pair}')
  Future <List<ForexDailyValue>> dailyValues(String pair)
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
    return mongoLayer.readDailyValues(pair).then(sendDailyValues);
  }

  @ApiMethod(path: 'dailyvaluesall/{date}')
  Future <List<ForexDailyValue>> dailyValuesAll(String date) async
  {
    List<Map> data = await mongoLayer.readDailyValueAll(DateTime.parse(date));
    List<ForexDailyValue> dailyvals=new List<ForexDailyValue>();
    for (Map mapDaily in data)
    {
      ForexDailyValue val = new ForexDailyValue.fromJson(mapDaily);
      dailyvals.add(val);
    }
    return dailyvals;
  }


  @ApiMethod(path: 'readdailyvalue/{pair}/{date}')
  Future<List<ForexDailyValue>> readDailyValue(String pair,String date) async
  {
    List<Map> data = await mongoLayer.readDailyValue(pair,DateTime.parse(date));
    List<ForexDailyValue> dailyvals=new List<ForexDailyValue>();
    for (Map mapDaily in data)
    {
       ForexDailyValue val = new ForexDailyValue.fromJson(mapDaily);
       dailyvals.add(val);
     }
    return dailyvals;
  }

  @ApiMethod(path: 'readdailyvaluemissing/{pair}/{date}')
  Future<List<ForexDailyValue>> readDailyValueMissing(String pair,String date) async
  {
    List<Map> data = await mongoLayer.readDailyValueMissing(pair,DateTime.parse(date));
    List<ForexDailyValue> dailyvals=new List<ForexDailyValue>();
    for (Map mapDaily in data)
    {
      ForexDailyValue val = new ForexDailyValue.fromJson(mapDaily);
      dailyvals.add(val);
    }
    return dailyvals;
  }

  @ApiMethod(path: 'readdailyvaluemissingall/{date}')
  Future<List<ForexDailyValue>> readDailyValueMissingAll(String date) async
  {
    List<Map> data = await mongoLayer.readDailyValueMissingAll(DateTime.parse(date));
    List<ForexDailyValue> dailyvals=new List<ForexDailyValue>();
    for (Map mapDaily in data)
    {
      ForexDailyValue val = new ForexDailyValue.fromJson(mapDaily);
      dailyvals.add(val);
    }
    return dailyvals;
  }

  @ApiMethod(path: 'dailyvaluesrange/{pair}/{startDate}/{endDate}')
  Future <List<ForexDailyValue>> dailyValuesRange(String pair,String startDate,String endDate) async
  {
    List<ForexDailyValue> dailyvals=new List<ForexDailyValue>();
    await for(Map dailyvalueMap in mongoLayer.readDailyValuesRangeAsync(pair,DateTime.parse(startDate),DateTime.parse(endDate)))
    {
      ForexDailyValue val = new ForexDailyValue.fromJson(dailyvalueMap);
      dailyvals.add(val);
    }

    await for(Map dailyvalueMap in mongoLayer.readDailyValuesRangeAsyncLatest(pair,DateTime.parse(startDate),DateTime.parse(endDate)))
    {
      ForexDailyValue val = new ForexDailyValue.fromJson(dailyvalueMap);
      dailyvals.add(val);
    }

     return dailyvals;
  }

  @ApiMethod(path: 'dailypricesrange/{pair}/{startDate}/{endDate}')
  Future <List<ForexDailyValue>> dailyPricesRange(String pair,String startDate,String endDate) async
  {
    List<ForexDailyValue> dailyvals=new List<ForexDailyValue>();
    await for(Map dailyvalueMap in mongoLayer.readPriceRangeAsyncByDate(pair,DateTime.parse(startDate),DateTime.parse(endDate)))
    {
      ForexDailyValue val = new ForexDailyValue.fromJson(dailyvalueMap);
      dailyvals.add(val);
    }

    return dailyvals;
  }


  @ApiMethod(path: 'dailyrealtimeprices/{pair}/{day}')
  Future <List<Price>> dailyRealTimePrices(String pair,String day) async
  {
    var dailyvals=<Price>[];
    await for(Map dailyvalueMap in mongoLayer.readPricesAsyncByDate(pair, DateTime.parse(day)))
    {
      var val = new Price.fromJsonMap(dailyvalueMap);
      dailyvals.add(val);
    }
     return dailyvals;
  }

  @ApiMethod(path: 'minutevalues/{pair}/{startDate}/{endDate}')
  Future <List<ForexDailyValue>> minuteValues(String pair,String startDate,String endDate)
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
    return mongoLayer.readMinuteValues(pair,DateTime.parse(startDate),DateTime.parse(endDate)).then(sendDailyValues);
  }

  @ApiMethod(path:'latestprices/{pair}')
  Future<Price> latestPrices(String pair) async
  {
      Map priceMap = await mongoLayer.readLatestPrice(pair);
      List<Price> latestPrices = new List<Price>();
      //latestPrices.add(new Price.fromJsonMap(priceMap));
      return new Price.fromJsonMap(priceMap);
  }

  @ApiMethod(path:'latestdailyprices/{pair}')
  Future<ForexDailyValue> latestDailyPrices(String pair) async
  {
    Map priceMap = await mongoLayer.readLatestDailyPrice(pair);
    List<ForexDailyValue> latestPrices = new List<ForexDailyValue>();
    //latestPrices.add(new Price.fromJsonMap(priceMap));
    return new ForexDailyValue.fromJson(priceMap);
  }

  @ApiMethod(path:'dailyindicator/{ruleName}/{windowStr}/{pair}/{currentDate}')
  Future<List<double>> indicator(String ruleName, String windowStr,String pair,String currentDate) async
  {
    int window = int.parse(windowStr);
    IndicatorRule tradingRule = new IndicatorRule(ruleName,window);
    var dailyRange = await mongoLayer
                            .readPriceRangeAsyncByDate(pair,DateTime.parse(currentDate).add(new Duration(days:-window))
                                                           ,DateTime.parse(currentDate)).toList();
    if(ruleName=="BelowBollingerBandLower")
      return [tradingRule.indicator(dailyRange).toStringAsFixed(5)];
    else
      return [tradingRule.indicator(dailyRange).toStringAsFixed(0)];
  }
  //TESTING Only
  @ApiMethod(path:'balancehistorypair/{sessionid}/{pair}/{strstartfilterdate}/{strendfilterdate}')
  Future<List<double>> balanceHistPair(String sessionid,String pair,String strstartfilterdate,String strendfilterdate) async
  {
    DateFormat formatter = new DateFormat('yyyyMMdd');

    Map currentSessionMap = await mongoLayer.readSession(sessionid);
    TradingSession currentSession = new TradingSession.fromJSONMap(currentSessionMap);
    DateTime startFilterDate = DateTime.parse(strstartfilterdate);
    DateTime endFilterDate = DateTime.parse(strendfilterdate).add(new Duration(days:1));
    List pairBalanceHistory = <double>[];
    findClosedTrades(String date)
    {
      return currentSession
          .sessionUser
          .primaryAccount
          .closedTrades
          .where((trade)=>trade.pair==pair)
          .where((trade)=>formatter.format(DateTime.parse(trade.closeDate))==date);
    }

    var sessionDates = currentSession
        .sessionUser
        .primaryAccount
        .balanceHistory
        .map((dailyVal)=>(DateTime.parse(dailyVal["date"])))
        .where((dailyVal)=>dailyVal.isAfter(startFilterDate))
        .where((dailyVal)=>dailyVal.isBefore(endFilterDate));

    double amount = currentSession
        .sessionUser
        .primaryAccount
        .balanceHistory[0]["amount"];



    var getCloseDates = new Set.from(currentSession
        .sessionUser
        .primaryAccount
        .closedTrades
        .where((trade)=>trade.pair==pair)
        .map((trade)=>formatter.format(DateTime.parse(trade.closeDate)))
        .toList()..sort());



    var setSessionDates = new Set.from(
      sessionDates.map((date)=>formatter.format(date))
                  .toList()..sort()
    );

    for(String sessionDate in setSessionDates)
    {
      //String sessionDate = formatter.format(sessionDateDt);
      if (getCloseDates.contains(sessionDate))
      {
        amount += findClosedTrades(sessionDate)
            .map((trade) => trade.PL())
            .reduce((t, e) => t + e);
      }
      pairBalanceHistory.add(amount);
    }

    return pairBalanceHistory;
  }

  @ApiMethod(path:'tradingtimehist/{sessionid}')
  Future<List<double>> TradingTimeHistogram(String sessionid) async
  {
    Map currentSessionMap = await mongoLayer.readSession(sessionid);
    TradingSession currentSession = new TradingSession.fromJSONMap(currentSessionMap);
    int DateDiff(Trade trade)
    {
      DateTime openDate = DateTime.parse(trade.openDate);
      DateTime closeDate = DateTime.parse(trade.closeDate);
      return closeDate.difference(openDate).inDays+1;
    }
    var a = currentSession
        .sessionUser
        .primaryAccount
        .closedTrades
        .map((trade)=>[trade.pair+trade.openDate,DateDiff(trade)])
        .toList();
    a.toList();
    return currentSession
        .sessionUser
        .primaryAccount
        .closedTrades
        .map((trade)=>[trade.pair+trade.openDate,DateDiff(trade)])
        .toList();
  }

  @ApiMethod(path:'plbalance/{sessionid}')
  Future<List<double>>  BarChartPLByPair(String sessionid) async
  {
    Map currentSessionMap = await mongoLayer.readSession(sessionid);
    TradingSession currentSession = new TradingSession.fromJSONMap(currentSessionMap);

    Set pairSet =new Set.from(currentSession
        .sessionUser
        .primaryAccount
        .closedTrades
        .map((trade)=>trade.pair)
        .toList()..sort());

    return pairSet.toList().map((pair)=>[pair,
    currentSession
        .sessionUser
        .primaryAccount
        .closedTrades
        .where((trade)=>trade.pair==pair)
        .map((trade)=>trade.PL())
        .reduce((x,y)=>x+y)
    ]).toList();
  }




}
