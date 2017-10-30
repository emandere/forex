library forex_mongo;
import 'package:mongo_dart/mongo_dart.dart';
import 'forex_classes.dart';
import 'forex_prices.dart';
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

  Stream readDailyValuesRangeAsync(pair,DateTime startDate,DateTime endDate ) async*
  {
    SelectorBuilder condition = where.eq("pair",pair).gte("datetime",startDate).lte("datetime",endDate);
    yield* db.collection('forexvalues').find(condition);
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

  Future<Map> readLatestPrice(String instrument)
  {
    SelectorBuilder condition = where.eq("instrument",instrument).sortBy("time",descending: true).limit(1);
    return db.collection('rawpriceslatest').findOne(condition);

  }

  Future<Map> readLatestDailyPrice(String instrument)
  {
    SelectorBuilder condition = where.eq("pair",instrument).sortBy("datetime",descending: true).limit(1);
    return db.collection('forexdailyprices').findOne(condition);

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
    SelectorBuilder condition = where.eq("pair",pair).gte("datetime",startDate).lte("datetime",endDate);
    return db.collection('forexvaluesminute').find(condition).toList();
  }

  Future<List<String>> readMongoPairs() async
  {
    List<String> pairs=new List<String>();
    await for(Map pairMap in db.collection('currencypairs').find())
    {
       pairs.add(pairMap["name"]);
    }
    return pairs;
  }

  Stream readMongoPairsAsync() async*
  {
     yield* db.collection('currencypairs').find();
  }


  Future<List<String>> readUserNames()
  {

    List<String> pairs=new List<String>();
    return db.collection('user').find().forEach(
        (pair)
    {

      pairs.add(pair["id"]);
    }
    ).then((dummy)=>pairs);
  }

  Future<List<String>> addUser(User user)
  {
    mongoAddUser()
    {


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

  AddServerStartTime(DateTime startTime) async
  {
      await db.collection("starttime").drop();
      await db.collection("starttime").insert({"time":startTime});
  }

  AddPrice(Price price) async
  {
      await db.collection("rawprices").save(price.toJson());
  }

  AddCurrentPrice(Price price) async
  {
     await db.collection("rawpriceslatest").remove({"instrument":price.instrument});
     await db.collection("rawpriceslatest").insert(price.toJson());
  }

  AddCandle(ForexDailyValue dailyValue) async
  {
    await db.collection("forexdailyprices").save(dailyValue.toJsonMap());
  }

  getStartTime() async
  {
    return await db.collection('starttime').findOne();
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

  Future<Map> readLatestCandle(String pair)
  {
    SelectorBuilder condition = where.eq("pair",pair).sortBy("datetime",descending: true).limit(1);
    return db.collection('forexdailyprices').findOne(condition);
  }

  Stream readPricesAsync(String pair) async*
  {
    SelectorBuilder condition = where.eq("instrument",pair);
    yield* db.collection('rawprices').find(condition);
  }

  Stream readPricesAsyncLatest(String pair,DateTime date) async*
  {
    SelectorBuilder condition = where.eq("instrument",pair).gte("time",date);
    yield* db.collection('rawprices').find(condition);
  }

  Stream readPricesAsyncByDate(String pair,DateTime date) async*
  {
    SelectorBuilder condition = where.eq("instrument",pair)
                                      .gte("time",date)
                                      .lte("time",date.add(new Duration(days:1)))
                                      .sortBy("time");
    yield* db.collection('rawprices').find(condition);
  }


  Stream readDailyAsyncByDate(String pair,DateTime date) async*
  {
    SelectorBuilder condition = where.eq("pair",pair)
        .gte("datetime",date)
        .lte("datetime",date.add(new Duration(days:1)))
        .sortBy("datetime");
    yield* db.collection('forexdailyprices').find(condition);
  }

  Stream<Map> readPriceRangeAsyncByDate(String pair,DateTime startDate,DateTime endDate) async*
  {
    SelectorBuilder condition = where.eq("pair",pair)
        .gte("datetime",startDate)
        .lte("datetime",endDate)
        .sortBy("datetime");
    yield* db.collection('forexdailyprices').find(condition);
  }

}