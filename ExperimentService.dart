import 'dart:io';
import 'lib/forex_classes.dart';
import 'lib/forex_mongo.dart';
main(List<String> arguments) async
{
   var arg = "debug";
   var isProcessing = false;
   if (arguments.length > 0)
      arg = arguments[0];
   ForexMongo mongoLayer = new ForexMongo(arg);
   await mongoLayer.db.open();


   TradingSession tradingSession1 = new TradingSession();
   tradingSession1.id="Exp1";
   //tradingSession1.strategy=strategy1;
   tradingSession1.startDate=DateTime.parse("20170601");
   tradingSession1.currentTime=tradingSession1.startDate;
   tradingSession1.endDate=DateTime.parse("20171101");
   //tradingSession1.lastUpdatedTime=new DateTime.now();
   tradingSession1.fundAccount("primary", 2000.0);



   Variable<int> xWindow = new Variable(name:"window", staticOptions: [15]);
   Variable<int> xUnits = new Variable(name:"units", staticOptions: [2000]);
   Variable<double> xStopLoss = new Variable(name:"stopLoss",start:1.001,stop:1.01,increment:0.001);
   Variable<double> xTakeProfit = new Variable(name:"takeProfit",staticOptions: [0.999]);
   Variable<String> xPosition = new Variable(name:"Position",staticOptions: ["short"]);
   Variable<String> xRuleName = new Variable(name:"ruleName",staticOptions: ["AboveBollingerBandHigher"]);
   //Variable<String> xRuleName = new Variable(name:"ruleName",staticOptions: ["RSIOverbought70"]);

   Experiment exp = new Experiment();
   exp.id = "firstTest6";
   exp.experimentSession = tradingSession1;
   exp.variables.add(xWindow);
   exp.variables.add(xStopLoss);
   exp.variables.add(xTakeProfit);
   exp.variables.add(xPosition);
   exp.variables.add(xRuleName);
   exp.variables.add(xUnits);
   await QueueSessions(exp,mongoLayer);
   exit(1);
}

QueueSessions(Experiment experiment,ForexMongo mongoLayer) async
{
   var sessions = experiment.GetExperimentSessions();
   for(var session in sessions)
   {
      await mongoLayer.pushTradingSession(session);
   }
}