import 'package:test/test.dart';
import '../forex_classes.dart';
class TestOrderClass
{
  testSuite()
  {
    test("Test Order Class Constructor",testOrderConstructor);
    test("Test Check Trigger",testCheckTrigger);
  }

  testOrderConstructor()
  {
    var testMap = getTestMap();
    var testOrder = new Order.fromJsonMap(testMap);
    Trade testTrade = testOrder.trade;

    expect(testOrder.above,false);
    expect(testOrder.expired, false);
    expect(testOrder.triggerprice, 50.0);
    expect(testOrder.expirationDate, "20170101");

    expect(testTrade.pair,"USDJPY");
    expect(testTrade.units, 100);
    expect(testTrade.openPrice, 100.0);
    expect(testTrade.Position(), 1);

    Map testJSONOut = testOrder.toJson();
    Order testOrder2 = new Order.fromJsonMap(testJSONOut);
    Trade testTrade2 = testOrder2.trade;

    expect(testOrder2.above,false);
    expect(testOrder2.expired, false);
    expect(testOrder2.triggerprice, 50.0);
    expect(testOrder2.expirationDate, "20170101");

    expect(testTrade2.pair,"USDJPY");
    expect(testTrade2.units, 100);
    expect(testTrade2.openPrice, 100.0);
    expect(testTrade2.Position(), 1);
  }

  getTestMap() {
    var testMapTrade ={};
    testMapTrade["pair"]="USDJPY";
    testMapTrade["units"]=100;
    testMapTrade["openDate"]="20110101";
    testMapTrade["closeDate"]="20120101";
    testMapTrade["long"]=true;
    testMapTrade["openPrice"]=100.0;
    testMapTrade["closePrice"]=101.0;
    testMapTrade["id"]=1;
    testMapTrade["init"]=true;

    var testMapOrder ={};
    testMapOrder["trade"]=testMapTrade;
    testMapOrder["expirationDate"]="20170101";
    testMapOrder["triggerprice"]=50.0;
    testMapOrder["expired"]=false;
    testMapOrder["above"]=false;


    return testMapOrder;
  }

  testCheckTrigger()
  {
    var testMap = getTestMap();
    var testOrder = new Order.fromJsonMap(testMap);

    expect(testOrder.checkTrigger(60.0), false);
    expect(testOrder.checkTrigger(40.0), true);

    testOrder.above=true;

    expect(testOrder.checkTrigger(60.0), true);
    expect(testOrder.checkTrigger(40.0), false);

  }


}