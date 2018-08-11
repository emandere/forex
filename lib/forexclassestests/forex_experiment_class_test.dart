import 'package:test/test.dart';
import '../forex_classes.dart';
class TestExperimentClass
{
  testSuite()
  {
    test("Test Generic Variable Constructor",testVariableConstructor);
    test("Test Cartesian Product",testCartesianProduct);
    test("Test Experiment",testExperiment);
  }

  testVariableConstructor()
  {
      Variable<int> xInt = new Variable(start:0,stop:5,increment:1);
      expect(xInt.options(), [0,1,2,3,4]);

      Variable<double> xDouble = new Variable(start:0,stop:5,increment:1);
      expect(xDouble.options(), [0,1,2,3,4]);

      Variable<String> xString = new Variable(staticOptions:["A","B","C"]);
      expect(xString.options(), ["A","B","C"]);

  }

  testCartesianProduct()
  {
    Variable<int> xInt = new Variable(name:"window", start:0,stop:5,increment:1);
    expect(xInt.options(), [0,1,2,3,4]);

    Variable<double> xDouble = new Variable(name:"stopLoss",start:0.0,stop:5.0,increment:1.0);
    expect(xDouble.options(), [0.0,1.0,2.0,3.0,4.0]);

    List<Strategy> product = xInt.CartesianProduct(<Strategy>[]);

    expect(product.length, 5);

    List<Strategy> twoproduct = xDouble.CartesianProduct(xInt.CartesianProduct(<Strategy>[]));

    expect(twoproduct.length, 25);
    expect(twoproduct[24].window, 4);
    expect(twoproduct[24].stopLoss, 4.0);


    Variable<int> test = new Variable(name:"window", staticOptions:[1]);
    Variable<double> test2 = new Variable(name:"stopLoss", staticOptions:[2.0]);
    List<Strategy> tp = test.CartesianProduct(test2.CartesianProduct(<Strategy>[]));
    expect(tp.length,1);
    expect(tp[0].window,1);
    expect(tp[0].stopLoss,2.0);
  }
  testExperiment()
  {
    Variable<int> xWindow = new Variable(name:"window", start:0,stop:5,increment:1);
    Variable<double> xStopLoss = new Variable(name:"stopLoss",start:0.0,stop:5.0,increment:1.0);
    Variable<double> xTakeProfit = new Variable(name:"takeProfit",start:0.0,stop:5.0,increment:1.0);

    Experiment exp = new Experiment();
    exp.variables.add(xWindow);
    exp.variables.add(xStopLoss);
    exp.variables.add(xTakeProfit);
    List<Strategy> expProduct = exp.GetStrategiesFromVariables();
    expect(expProduct.length,125);

    expect(expProduct[124].window, 4);
    expect(expProduct[124].stopLoss, 4.0);
    expect(expProduct[124].takeProfit, 4.0);
  }
}