import 'package:test/test.dart';
import 'lib/forexclassestests/forex_trade_class_test.dart';
import 'lib/forexclassestests/forex_strategy_class_test.dart';
import 'lib/forexclassestests/forex_order_class_test.dart';
import 'lib/forexclassestests/forex_account_class_test.dart';
import 'lib/forexclassestests/forex_user_class_test.dart';
import 'lib/forexclassestests/forex_tradingsession_class_test.dart';
void main()
{
    TestTradeClass tradeClass = new TestTradeClass();
    TestStrategyClass strategyClass=new TestStrategyClass();
    TestOrderClass orderClass = new TestOrderClass();
    TestAccountClass accountClass=new TestAccountClass();
    TestUserClass userClass = new TestUserClass();
    TestTradingSessionClass tradingSessionClass = new TestTradingSessionClass();

    tradeClass.testSuite();
    strategyClass.testSuite();
    orderClass.testSuite();
    accountClass.testSuite();
    userClass.testSuite();
    tradingSessionClass.testSuite();
}

