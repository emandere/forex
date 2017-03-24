import 'dart:async';

import 'dart:io';

import 'lib/forex_classes.dart';
import 'lib/forex_mongo.dart';
import 'lib/candle_stick.dart';
import 'lib/forex_stats.dart';

import 'dart:collection';

import 'package:parallel/parallel.dart';
import 'package:worker/worker.dart';



/*class TestStrategies
{
  TestStrategies( )
  {

  }
  call(ForexCache cache)
  {
     return TestSingleStrategy(cache);
  }
  TestSingleStrategy(List args)
  {
    Map cache = args[0];
    String server ="23.22.66.239";
    String startDate = "2002-12-31";
    String endDate = "2012-01-01";
    String rulePosition="long";
    String ruleName = args[1];
    String account = "primary";

    double takeProfitPct = 0.003;
    double stopLossPct = 0.01;
    double takeProfit = 1.0;
    double stopLoss = 1.0;

    int window = 14;
    TestStrategy
      ( cache,
        rulePosition,
        takeProfit,
        takeProfitPct,
        stopLoss,
        stopLossPct,
        ruleName,
        window,
        startDate,
        endDate,
        server,
        account);

    return "success";
  }

  TestStrategy(
      Map cache,
      String rulePosition,
      double takeProfit,
      double takeProfitPct,
      double stopLoss,
      double stopLossPct,
      String ruleName,
      int window,
      String startDate,
      String endDate,
      String server,
      String account) async {
    if(rulePosition=="long")
    {
      takeProfit+=takeProfitPct;
      stopLoss-=stopLossPct;
    }
    else
    {
      takeProfit-=takeProfitPct;
      stopLoss+=stopLossPct;
    }

    int units = 15000;

    IndicatorRule tradingRule = new IndicatorRule(ruleName,window);
    List<IndicatorRule> rules = new List<IndicatorRule>();
    rules.add(tradingRule);

    //ForexCache cache = new ForexCache(startDate,endDate,rules);
    //await cache.buildCache(server);

    //print("cache built");
    //cache.DailyValues();


    TradingSession testSession=new TradingSession();
    testSession.id='testSession$ruleName';
    testSession.sessionUser.id="testSessionUserNewSlope";
    testSession.startDate = DateTime.parse(startDate);
    testSession.fundAccount("primary",2000.0);
    Stopwatch watch = new Stopwatch();
    watch.start();
    var currentyear = "0";
    for(var dailyPairValues in cache.DailyValues())
    {
      for(Map dailyPairValue in dailyPairValues)
      {
        if(dailyPairValue[ruleName]) {

          testSession.executeTrade(
              account,
              dailyPairValue["pair"],
              units,
              rulePosition,
              dailyPairValue["date"],
              dailyPairValue["close"],
              stopLoss * dailyPairValue["close"],
              takeProfit * dailyPairValue["close"]);
        }
      }
      testSession.updateSession(dailyPairValues);
    }
    watch.stop();

    testSession.printacc();
    print(watch.elapsedMilliseconds.toString());


    PostData myData = new PostData();
    myData.data=testSession.toJson();

    var url = 'http://$server/api/forexclasses/v1/addsessionpost';
    //var response = await http.post(url,body:myData.toJsonMap());
    //print("Response status: ${response.statusCode}");
    //print("Response body: ${response.body}");
  }
}*/

main()  async {
  Worker worker = new Worker();
  Task task = new AckermannTask(1, 2);

  Worker worker2 = new Worker();
  Task task2 = new AckermannTask(1, 2);


  List results=await Future.wait([worker.handle(task),worker2.handle(task2)]);

  for(var result in results) {
    print(result);
  }
  exit(0);
}

class AckermannTask implements Task {
  int x, y;

  AckermannTask (this.x, this.y);

  int execute () {
    return ackermann(x, y);
  }

  int ackermann (int m, int n) {
    return 20;
  }
}



