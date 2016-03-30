library forex_data;
import 'dart:io';
import 'package:rpc/rpc.dart';
import 'package:path/path.dart' as path;
import 'candle_stick.dart';
import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';

@ApiClass(
    name: 'forex',  // Optional (default is 'cloud' since class name is Cloud).
    version: 'v1'
)
class ForexData
{
  var db;
  var mongoCurrencyPairs;
  ForexData();

  @ApiMethod(path: 'mongopairs')
  Future<List<String>> readMongoPairs()
  {
    db = new Db("mongodb://localhost/testdb");
    return db.open().then(updateCurrencyMongo);//.then(closedb);

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


  @ApiMethod(path: 'pairs')
  List<String> pairs()
  {
    List<String> pairNames = new List<String>();
    Directory forexDirectory = new Directory("C:/ForexData");
    List contents = forexDirectory.listSync();
    for (FileSystemEntity fileOrDir in contents)
    {
      pairNames.add(path.basename(fileOrDir.path));
    }
    return pairNames;
  }
  @ApiMethod(path: 'dailyvalues/{pair}')
  List<ForexDailyValue> dailyValues(String pair)
  {

    List<String> strvalues = new File('C:/ForexData/'+pair+'/'+pair+'dailyval.txt').readAsLinesSync();
    List<ForexDailyValue> dailyvals=new List<ForexDailyValue>();
    print("Here3");
    for(String line in strvalues)
    {
      ForexDailyValue val = new ForexDailyValue.fromString(line,pairName:pair);
      dailyvals.add(val);
    }
    return dailyvals;
  }

}