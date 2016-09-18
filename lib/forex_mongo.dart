library forex_mongo;
import 'package:mongo_dart/mongo_dart.dart';
import 'forex_classes.dart';
import 'candle_stick.dart';
import 'dart:async';
import 'dart:convert';
class ForexMongo
{
  Db db;
  ForexMongo(String mode)
  {
    //db = new Db("mongodb://localhost/testdb");
    if(mode=="debug")
    {
      db = new Db("mongodb://localhost/testdb");

    }
    else
    {
      db = new Db("mongodb://mongo:27017/testdb");
    }
  }

  Future<List<Map>> readDailyValues(pair)
  {
    print ("here");
    return db.collection('forexvalues').find({"pair":pair}).toList();
  }

  Future<Map> readSession(String id)
  {
    return db.collection('session').findOne({"id":id});
  }

  Future<List<Map>> readDailyValuesRange(pair,DateTime startDate,DateTime endDate)
  {
    SelectorBuilder condition = where.eq("pair",pair).gte("datetime",startDate).lte("datetime",endDate);
    //SelectorBuilder condition = where.eq("pair",pair).eq("datetime",startDate);
    return db.collection('forexvalues').find(condition).toList();
  }

  Future<List<Map>> readDailyValue(pair,DateTime currDate)
  {
    //SelectorBuilder condition = where.eq("pair",pair).gte("datetime",startDate).lte("datetime",endDate);
    SelectorBuilder condition = where.eq("pair",pair).eq("datetime",currDate);
    return db.collection('forexvalues').find(condition).toList();
  }

  Future<List<Map>> readDailyValueAll(DateTime currDate)
  {
    //SelectorBuilder condition = where.eq("pair",pair).gte("datetime",startDate).lte("datetime",endDate);
    SelectorBuilder condition = where.eq("datetime",currDate);
    return db.collection('forexvalues').find(condition).toList();
  }

  Future<List<Map>> readDailyValueMissing(pair,DateTime startDate)
  {
    SelectorBuilder condition = where.eq("pair",pair).gte("datetime",startDate.add(new Duration(days:-7))).lte("datetime",startDate);
    return db.collection('forexvalues').find(condition).toList();
  }

  Future<List<Map>> readDailyValueMissingAll(DateTime startDate)
  {
    SelectorBuilder condition = where.gte("datetime",startDate.add(new Duration(days:-7))).lte("datetime",startDate);
    return db.collection('forexvalues').find(condition).toList();
  }


  Future<List<Map>> readMinuteValues(pair,DateTime startDate,DateTime endDate)
  {
    print ("here");
    SelectorBuilder condition = where.eq("pair",pair).gte("datetime",startDate).lte("datetime",endDate);
    return db.collection('forexvaluesminute').find(condition).toList();
  }

  Future<List<String>> readMongoPairs()
  {
    print ("here");
    List<String> pairs=new List<String>();
    return db.collection('currencypairs').find().forEach(
            (pair)
        {
          print (pair["name"]);
          pairs.add(pair["name"]);
        }
    ).then((dummy)=>pairs);
  }

  Future<List<String>> readUserNames()
  {
    print ("here");
    List<String> pairs=new List<String>();
    return db.collection('user').find().forEach(
        (pair)
    {
      print (pair["id"]);
      pairs.add(pair["id"]);
    }
    ).then((dummy)=>pairs);
  }

  Future<List<String>> addUser(User user)
  {
    mongoAddUser()
    {
      print("Adding USer");
      print(user.toJson());
      return db.collection('user').insert(user.toJsonMap());
    }
    mongoResult(var result)
    {
      List<String> testuser=new List<String>();
      testuser.add(user.id+" Added");
      return testuser;
    }
    return mongoAddUser().then(mongoResult);//.then(closedb);
  }

  Future<List<String>> removeUser(User user)
  {
    mongoRemoveUser()
    {
      return db.collection('user').remove({"id":user.id});
    }
    mongoResult(var result)
    {
      List<String> respond = new List<String>();
      respond.add(user.id+" Deleted");
      return respond;
    }
    return mongoRemoveUser().then(mongoResult);
  }

  Future<List<String>> removeUserById(String userId)
  {
    mongoRemoveUser()
    {
      return db.collection('user').remove({"id":userId});
    }
    mongoResult(var result)
    {
      List<String> respond = new List<String>();
      respond.add(userId+" Deleted");
      return respond;
    }
    return mongoRemoveUser().then(mongoResult);
  }

  Future<List<String>> saveUser(User user)
  {
    mongoSaveUser()
    {
      return db.collection('user').save(user.toJsonMap());
    }

    mongoResult(var result)
    {
      List<String> respond = new List<String>();
      respond.add(user.id+" Saved");
      return respond;
    }
    return mongoSaveUser().then(mongoResult);
  }

   saveSession(TradingSession session) async
   {
     return db.collection('session').save(session.toJsonMap());
   }



  Stream<Map> getSessions()
  {
    return db.collection('session').find();
  }

  Future<Map> getUser(String id)
  {

      return db.collection('user').findOne({"_id":id});
  }

  Future<List<String>> deleteUser(User user)
  {
    mongoDeleteUser()
    {
      return db.collection('user').remove(where.eq("_id",user.id));
    }

    mongoResult(var result)
    {
      List<String> respond = new List<String>();
      respond.add(user.id+" Deleted");
      return respond;
    }
    return mongoDeleteUser().then(mongoResult);
  }

  AddCurrencies(List<String> currencies) async
  {
    await db.collection("currencypairs").drop();
     for(String pair in currencies)
     {
       await db.collection("currencypairs").insert({"name":pair});
     }
  }

  ClearForexValues() async
  {
    await db.collection('forexvalues').drop();
  }

  Future<List<String>> addForexDailyValue(ForexDailyValue value)
  {
    mongoAddForexDailyValue()
    {
      return db.collection('forexvalues').insert(value.toJsonMap());
    }
    mongoResult(var result)
    {
      List<String> testuser=new List<String>();
      testuser.add(value.pair+" "+value.date+" Added");
      return testuser;
    }
    //return db.open().then(mongoAddForexDailyValue).then(mongoResult);
    return mongoAddForexDailyValue().then(mongoResult);
  }

  Future<List<String>> addForexMinuteValue(ForexDailyValue value)
  {
    mongoAddForexDailyValue()
    {
      return db.collection('forexvaluesminute').insert(value.toJsonMap());
    }
    mongoResult(var result)
    {
      List<String> testuser=new List<String>();
      testuser.add(value.pair+" "+value.date+" "+value.time+" Added");
      return testuser;
    }
    //return db.open().then(mongoAddForexDailyValue).then(mongoResult);
    return mongoAddForexDailyValue().then(mongoResult);
  }



}