
import 'package:mongo_dart/mongo_dart.dart';
import 'package:rpc/rpc.dart';
import 'dart:async';
import 'forex_classes.dart';
import 'forex_mongo.dart';
import 'candle_stick.dart';
import 'dart:convert';


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

  @ApiMethod(path: 'sessions')
  Future<List<String>> getSessions() async
  {
    List<String> sessions=new List<String>();
    await for (Map session in mongoLayer.getSessions())
    {
      sessions.add(session["id"]);
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
      for(var mypair in testpairs)
      {
        print (mypair);
      }
      print('closing db');
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
  Future<List<String>> addSessionPost(PostData sessionData)
  {
    print(sessionData.data);
    TradingSession session=new TradingSession.fromJSON(sessionData.data);
    return mongoLayer.saveSession(session);
  }

  @ApiMethod(method: 'POST',path: 'adduserpost')
  Future<List<String>> addUserPost(UserData fuser)
  {
    User user = new User.fromJson(fuser.data);
    print(fuser.data);
    return mongoLayer.addUser(user);
    /*//Map jsonuser = JSON.decode(userdata.data);
    print(user.toJson());
    //User user = new User.fromJson(userdata);
    //print(user.id);
    showMongoUser(var result)
    {

      List<String> testuser=new List<String>();
      testuser.add(user.id);
      return testuser;
      /*return db.collection('user').find(where.eq('id',user.id)).forEach(
              (user)
          {
            testuser.add(user.id);

          }).then((dummy){return testuser;});
      //return "Success";*/
    }

    mongoAddUser(var result)
    {
      //User user = new User(name);
      return db.collection('user').insert(JSON.decode(user.toJson()));
    }
    db = new Db("mongodb://localhost/testdb");
    return db.open().then(mongoAddUser).then(showMongoUser);//.then(closedb);*/

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

  @ApiMethod(path: 'dailyvaluesrange/{pair}/{startDate}/{endDate}')
  Future <List<ForexDailyValue>> dailyValuesRange(String pair,String startDate,String endDate)
  {
    List<ForexDailyValue> dailyvals=new List<ForexDailyValue>();
    print("Here we are");
    sendDailyValues(mapValues)
    {
      for (Map mapDaily in mapValues)
      {
        ForexDailyValue val = new ForexDailyValue.fromJson(mapDaily);
        dailyvals.add(val);
      }
      return dailyvals;
    }
    return mongoLayer.readDailyValuesRange(pair,DateTime.parse(startDate),DateTime.parse(endDate)).then(sendDailyValues);
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


}
