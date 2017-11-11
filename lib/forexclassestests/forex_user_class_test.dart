import 'package:test/test.dart';
import '../forex_classes.dart';
import '../forex_prices.dart';
class TestUserClass
{
  testSuite()
  {
    test("Test User Class Constructor",testUserConstructor);
    test("Test User Class Realized PL",testRealizedPL);
    test("Test User Class Execute Price Strategy",testExecutePriceStrategy);
  }

  testUserConstructor()
  {
    var testUser = new User.fromJsonMap(getTestMapUser());

    expect(testUser.id, "testUser");

    var testUser2 = new User.fromJsonMap(testUser.toJsonMap());

    expect(testUser2.id, "testUser");
    expect(testUser2.status, "live");
    expect(testUser2.primaryAccount.MarginRatio, 50.0);

  }

  testRealizedPL()
  {
    var testUser = new User.fromJsonMap(getTestMapUser());
    expect(testUser.RealizedPL(), 0.0);
  }

  testFundAccount()
  {
    var testUser = new User.fromJsonMap(getTestMapUser());
    var testAccount = testUser.primaryAccount;

    testAccount.fundAccount(2000.0);

    expect(testAccount.cash, 2000.0);
  }

  testExecuteTrade()
  {
    var testUser = new User.fromJsonMap(getTestMapUser());
    var testAccount = testUser.primaryAccount;
    var testTrade = new Trade.fromJsonMap(getTestMapTrade());
    var testTradeOpposite = new Trade.fromJsonMap(getTestMapTradeOpposite());
    testAccount.fundAccount(2000.0);

    expect(testAccount.Trades.length, 0);
    testAccount.executeTrade(testTrade);
    expect(testAccount.Trades.length, 1);
    expect(testAccount.Trades[0].pair, "USDJPY");
    testAccount.executeTrade(testTradeOpposite);
    expect(testAccount.Trades.length, 0);




    testAccount.processOrdersNew("USDJPY", 60.0);
    expect(testAccount.Trades.length, 0);
    testAccount.processOrdersNew("USDJPY", 40.0);
    expect(testAccount.Trades.length, 1);
    expect(testAccount.MarginUsed(), 2.02);
    expect(testAccount.closedTrades.length, 1);
    expect(testAccount.PL(), 2);



  }

  testStopLoss()
  {
    var testUser = new User.fromJsonMap(getTestMapUser());
    var testAccount = testUser.primaryAccount;
    var testTrade = new Trade.fromJsonMap(getTestMapTrade());

    testAccount.orders.clear();

    testAccount.executeTrade(testTrade);
    testAccount.setStopLoss(testTrade, 90.0);

    expect(testAccount.orders.length,1);
    expect(testAccount.orders[0].above, false);

    testAccount.processOrdersNew("USDJPY", 91.0);
    expect(testAccount.Trades.length, 1);

    testAccount.processOrdersNew("USDJPY", 90.0);
    expect(testAccount.Trades.length, 0);
  }


  testTakeProfit()
  {
    var testUser = new User.fromJsonMap(getTestMapUser());
    var testAccount = testUser.primaryAccount;
    var testTrade = new Trade.fromJsonMap(getTestMapTrade());

    testAccount.orders.clear();

    testAccount.executeTrade(testTrade);
    testAccount.setTakeProfit(testTrade, 104.0);

    expect(testAccount.orders.length,1);
    expect(testAccount.orders[0].above, true);

    testAccount.processOrdersNew("USDJPY", 103.0);
    expect(testAccount.Trades.length, 1);

    testAccount.processOrdersNew("USDJPY", 104.0);
    expect(testAccount.Trades.length, 0);
  }

  testExecutePriceStrategy()
  {
    Price testPrice = new Price();
    testPrice.instrument="USDJPY";
    testPrice.bid=107.0;
    testPrice.time=new DateTime.now();

    var testUser = new User.fromJsonMap(getTestMapUser());
    var testAccount = testUser.primaryAccount;
    var testTrade = new Trade.fromJsonMap(getTestMapTrade());

    testAccount.orders.clear();

    testAccount.executeTrade(testTrade);
    testAccount.setTakeProfit(testTrade, 104.0);

    expect(testAccount.orders.length,1);

    testUser.updateTradesPrice(testPrice);
    expect(testUser.primaryAccount.Trades[0].closePrice, testPrice.bid);
  }


  getTestMapUser()
  {
     var Accounts=<String,Map>{};
     Accounts["primary"]=getTestMapAccountPrimary();
     Accounts["secondary"]=getTestMapAccountSecondary();
     var testMapUser={};
     testMapUser["id"]="testUser";
     testMapUser["status"]="live";
     testMapUser["Accounts"]=Accounts;

     return testMapUser;

  }

  getTestMapAccountPrimary()
  {
    var testMapAccount={};
    List<Map> MapTrades = new List<Map>();
    List<Map> MapClosedTrades = new List<Map>();
    List<Map> MapOrders=new List<Map>();

    MapOrders.add(getTestMapOrder());

    testMapAccount["id"]="primary";
    testMapAccount["cash"]=0.0;
    testMapAccount["Margin"]=0.0;
    testMapAccount["MarginRatio"]=50.0;
    testMapAccount["idcount"]=0;
    testMapAccount["realizedPL"]=0.0;
    testMapAccount["Trades"]=MapTrades;
    testMapAccount["closedTrades"]=MapClosedTrades;
    testMapAccount["orders"]=MapOrders;

    return testMapAccount;
  }

  getTestMapAccountSecondary()
  {
    var testMapAccount={};
    List<Map> MapTrades = new List<Map>();
    List<Map> MapClosedTrades = new List<Map>();
    List<Map> MapOrders=new List<Map>();

    MapOrders.add(getTestMapOrder());

    testMapAccount["id"]="secondary";
    testMapAccount["cash"]=0.0;
    testMapAccount["Margin"]=0.0;
    testMapAccount["MarginRatio"]=50.0;
    testMapAccount["idcount"]=0;
    testMapAccount["realizedPL"]=0.0;
    testMapAccount["Trades"]=MapTrades;
    testMapAccount["closedTrades"]=MapClosedTrades;
    testMapAccount["orders"]=MapOrders;

    return testMapAccount;
  }

  getTestMapOrder() {
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

  getTestMapTrade()
  {
    var testMap ={};
    testMap["pair"]="USDJPY";
    testMap["units"]=100;
    testMap["openDate"]="20110101";
    testMap["closeDate"]="20120101";
    testMap["long"]=true;
    testMap["openPrice"]=100.0;
    testMap["closePrice"]=101.0;
    testMap["id"]=1;
    testMap["init"]=true;
    return testMap;
  }

  getTestMapTradeOpposite()
  {
    var testMap ={};
    testMap["pair"]="USDJPY";
    testMap["units"]=100;
    testMap["openDate"]="20110101";
    testMap["closeDate"]="20120101";
    testMap["long"]=false;
    testMap["openPrice"]=100.0;
    testMap["closePrice"]=101.0;
    testMap["id"]=1;
    testMap["init"]=true;
    return testMap;
  }


}