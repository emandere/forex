import 'package:test/test.dart';
import '../forex_classes.dart';
import '../forex_prices.dart';
class TestAccountClass
{
  testSuite()
  {
    test("Test Account Class Constructor",testAccountConstructor);
    test("Test Account Class Fund Account",testFundAccount);
    test("Test Account Class Execute Trade",testExecuteTrade);
    test("Test Account Class Stop Loss",testStopLoss);
    test("Test Account Class Take Profit",testTakeProfit);
    test("Test Account Class Test Update Price",testUpdatePrice);
  }

  testAccountConstructor()
  {
    var testAccount = new Account.fromJsonMap(getTestMapAccount());

    expect(testAccount.id, "primary");
    expect(testAccount.orders.length,1 );
    expect(testAccount.closedTrades.length,0 );
    expect(testAccount.Trades.length, 0);
    expect(testAccount.MarginRatio,50.0 );
    expect(testAccount.Margin,0.0 );
    expect(testAccount.orders[0].expirationDate, "20170101");
    expect(testAccount.balanceHistory[1]["date"], "2017-05-03T03:02:03.636Z");

    var testAccount2 = new Account.fromJsonMap(testAccount.toJson());

    expect(testAccount2.id, "primary");
    expect(testAccount2.orders.length,1 );
    expect(testAccount2.closedTrades.length,0 );
    expect(testAccount2.Trades.length, 0);
    expect(testAccount2.MarginRatio,50.0 );
    expect(testAccount2.Margin,0.0 );
    expect(testAccount2.orders[0].expirationDate, "20170101");

  }

  testFundAccount()
  {
    var testAccount = new Account.fromJsonMap(getTestMapAccount());

    testAccount.fundAccount(2000.0);

    expect(testAccount.cash, 2000.0);
  }

  testExecuteTrade()
  {
    var testAccount = new Account.fromJsonMap(getTestMapAccount());
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
    var testAccount = new Account.fromJsonMap(getTestMapAccount());
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
    var testAccount = new Account.fromJsonMap(getTestMapAccount());
    var testTrade = new Trade.fromJsonMap(getTestMapTrade());

    testAccount.orders.clear();

    testAccount.executeTrade(testTrade);
    testAccount.setTakeProfit(testTrade, 104.0);

    expect(testAccount.orders.length,1);
    expect(testAccount.orders[0].above, true);

    testAccount.processOrdersNew("USDJPY", 103.0);
    expect(testAccount.Trades.length, 1);

    Account testAccount2 = new Account.fromJsonMap(testAccount.toJson());
    expect(testAccount2.Trades[0].takeProfit,104);

    testAccount.processOrdersNew("USDJPY", 104.0);
    expect(testAccount.Trades.length, 0);
  }

  testUpdatePrice()
  {
    var testAccount = new Account.fromJsonMap(getTestMapAccount());
    var testTrade = new Trade.fromJsonMap(getTestMapTrade());

    testAccount.orders.clear();

    testAccount.executeTrade(testTrade);
    testAccount.setTakeProfit(testTrade, 104.0);

    Price testPrice = new Price();
    testPrice.instrument="USDJPY";
    testPrice.bid=107.0;
    testPrice.time=new DateTime.now();

    testAccount.updateTradesPrice(testPrice);

    expect(testAccount.Trades[0].closePrice, testPrice.bid);
  }


  getTestMapAccount()
  {
    var testMapAccount={};
    List<Map> MapTrades = new List<Map>();
    List<Map> MapClosedTrades = new List<Map>();
    List<Map> MapOrders=new List<Map>();
    List<Map<String,double>> MapBalanceHistory=getTestMapHistory();

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
    testMapAccount["balanceHistory"]=MapBalanceHistory;
    return testMapAccount;
  }

  getTestMapHistory()
  {
    List<Map<String,double>> MapBalanceHistory=<Map<String,double>>[];
    MapBalanceHistory.add({"date":"2017-05-02T03:02:03.636Z","amount":100.0});
    MapBalanceHistory.add({"date":"2017-05-02T03:03:03.636Z","amount":101.0});
    MapBalanceHistory.add({"date":"2017-05-03T03:02:03.636Z","amount":102.0});
    MapBalanceHistory.add({"date":"2017-05-03T03:04:03.636Z","amount":103.0});
    MapBalanceHistory.add({"date":"2017-05-04T03:04:03.636Z","amount":103.0});
    return MapBalanceHistory;
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