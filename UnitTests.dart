import 'package:test/test.dart';
import 'lib/forexclassestests/forex_trade_class_test.dart';
import 'lib/forexclassestests/forex_strategy_class_test.dart';
void main()
{
    TestTradeClass tradeClass = new TestTradeClass();
    TestStrategyClass strategyClass=new TestStrategyClass();
    tradeClass.testSuite();
    strategyClass.testSuite();
}

