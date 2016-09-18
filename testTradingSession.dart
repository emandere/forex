import 'lib/forex_classes.dart';
import 'lib/forex_mongo.dart';
import 'lib/candle_stick.dart';
import 'dart:async';
import 'dart:io';

ForexMongo mongoLayer;
Timer myTimer;
DateTime sessionTime;
TradingSession testSession;
bool play=false;
main() async
{

   mongoLayer= new ForexMongo("debug");
   await mongoLayer.db.open();
   testSession=new TradingSession();
   testSession.id="testSession77";
   testSession.sessionUser.id="testSessionUser77";

   String line ="";
   Duration timeElapsed=new Duration(seconds:1);

   while(line!="exit")
   {
      print(">");
      line = stdin.readLineSync();

      if(play)
      {
         timeElapsed=-sessionTime.difference(new DateTime.now());

      }
      else
      {
         sessionTime=new DateTime.now();
         timeElapsed=new Duration(seconds:0);
      }

      for(int i=0;i<timeElapsed.inSeconds;i++)
      {
         await testSession.updateTime(1,mongoLayer.readDailyValue,mongoLayer.readDailyValueMissing);
         testSession.updateHistory();
         mongoLayer.saveSession(testSession);
         await testSession.processOrders(mongoLayer.readDailyValue,mongoLayer.readDailyValueMissing);
      }

      await testSession.updateTime(0,mongoLayer.readDailyValue,mongoLayer.readDailyValueMissing);

      print("> Added $line\n");
      if(line=="playpause")
      {
         print("here");
         playPauseEvent();
      }

      if(line=="showtime")
      {
         print(testSession.currentTime.toString());
      }

      if(line=="showprice")
      {
         print(testSession.currentTime.toString());
         for(String pair in testSession.sessionUser.TradingPairs())
         {
            print(pair);
            String dt = testSession.currentTime.toString();//.split(' ')[0];
            List<ForexDailyValue> val = await testSession.dailyValuesRange(pair,dt,mongoLayer.readDailyValue,mongoLayer.readDailyValueMissing);
            if(val.length>0)
               print(val[0].close.toString());
         }
      }

      if(line=="showacc")
      {
         print(testSession.currentTime.toString());
         print(testSession.sessionUser.id);

         testSession.sessionUser.printacc();
      }

      if(line.startsWith("close"))
      {
         List<String> parts = line.split(' ');
         testSession.closeTrade(parts[1],int.parse(parts[2]));
         testSession.sessionUser.printacc();
      }

      //Example
      //exec primary EURUSD 1000 long
      if(line.startsWith("exec"))
      {
         List<String> parts = line.split(' ');
         //testSession.executeTrade(parts[1],parts[2],int.parse(parts[3]),parts[4],testSession.currentTime.toString());
         await testSession.updateTime(timeElapsed.inSeconds,mongoLayer.readDailyValue,mongoLayer.readDailyValueMissing);
         testSession.sessionUser.printacc();
      }


      if(line.startsWith("order"))
      {
         List<String> parts = line.split(' ');
         if(parts[3]=="above")
            testSession.setOrder(parts[1],int.parse(parts[2]),double.parse(parts[3]),true);
         else
            testSession.setOrder(parts[1],int.parse(parts[2]),double.parse(parts[3]),false);
      }

      if(line.startsWith("fund"))
      {
         List<String> parts = line.split(' ');
         testSession.fundAccount(parts[1],double.parse(parts[2]));
      }

      if(line.startsWith("transfer"))
      {
         List<String> parts = line.split(' ');
         testSession.transferAmount(parts[1],parts[2],double.parse(parts[3]));
      }

      if(line.startsWith("save"))
      {
         mongoLayer.saveSession(testSession);
      }

      if(line.startsWith("session"))
      {
         print("cmon!!");
         await for (Map sess in mongoLayer.getSessions())
         {
            print(sess["id"]);
         }

      }

   }

   print("closed");
   exit(1);
}

playPauseEvent()
{

   if(play)
   {
      play=false;
   }
   else
   {
      play=true;
   }
}