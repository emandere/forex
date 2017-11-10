import 'package:test/test.dart';
import '../forex_classes.dart';
class TestTradeClass
{
    testSuite()
    {
      test("Test Trade Class Constructor",testTradeConstructor);
      test("Test Trade Class PL", testPL);
    }

    testTradeConstructor()
    {
      var testMap = getTestMap();

      Trade test = new Trade.fromJsonMap(testMap);
      expect(test.pair,"USDJPY");
      expect(test.units, 100);
      expect(test.openPrice, 100.0);
      expect(test.Position(), 1);

      Map testJSONOut = test.toJson();
      Trade test2 = new Trade.fromJsonMap(testJSONOut);
      expect(test2.pair,"USDJPY");
      expect(test2.units, 100);
      expect(test2.openPrice, 100.0);
      expect(test2.Position(), 1);
    }

    getTestMap() {
      var testMap ={};
      testMap["pair"]="USDJPY";
      testMap["units"]=100;
      testMap["openDate"]="20110101";
      testMap["closeDate"]="20120101";
      testMap["long"]=true;
      testMap["openPrice"]=100.0;
      testMap["closePrice"]=101.0;
      testMap["id"]=1;
      return testMap;
    }

    testPL()
    {

      var testMap = getTestMap();

      Trade test = new Trade.fromJsonMap(testMap);
      expect(test.PL(), 1);

    }
}