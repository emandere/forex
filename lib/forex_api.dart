
import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:rpc/rpc.dart';
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

  @ApiMethod(path: 'pairs')
  Future<List<String>> readMongoPairs()
  {
    return mongoLayer.readMongoPairs();
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
    await mongoLayer.saveSession(session);
    return success;
  }


  @ApiMethod(method: 'POST',path: 'adduserpost')
  Future<List<String>> addUserPost(UserData fuser)
  {
    User user = new User.fromJson(fuser.data);
    return mongoLayer.addUser(user);
  }

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

  @ApiMethod(method: 'POST',path: 'removeuser')
  Future<List<String>> removeUser(UserData userid)
  {
     return mongoLayer.removeUserById(userid.data);
  }

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

  @ApiMethod(path:'dailyindicator/{ruleName}/{windowStr}/{pair}/{currentDate}')
  Future<List<double>> indicator(String ruleName, String windowStr,String pair,String currentDate) async
  {
    int window = int.parse(windowStr);
    IndicatorRule tradingRule = new IndicatorRule(ruleName,window);
    var dailyRange = await mongoLayer
                            .readPriceRangeAsyncByDate(pair,DateTime.parse(currentDate).add(new Duration(days:-window))
                                                           ,DateTime.parse(currentDate)).toList();

    return [tradingRule.indicator(dailyRange).toStringAsFixed(0)];
  }

}
