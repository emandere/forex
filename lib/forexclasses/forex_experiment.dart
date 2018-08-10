part of forex_classes;
class Variable<T>
{
  final String name;
  final T start;
  final T stop;
  final T increment;
  final List<T> staticOptions;
  const Variable({this.start,this.stop,this.increment,this.staticOptions,this.name});

  List<T> options()
  {
      if(staticOptions!=null)
        return staticOptions;

      List<T> returnList = <T>[];
      for (var i = start; i < stop; i += increment)
      {
        returnList.add(i);
      }

      return returnList;
  }

   List<Strategy> CartesianProduct(List<Strategy> currentProduct)
   {
      var returnNewList = <Strategy>[];
      if(currentProduct.isEmpty)
      {
        for(var currentValue in options())
        {
          returnNewList.add(createStrategy(new Strategy(), currentValue));
        }
        return returnNewList;
      }

      for(Strategy currentStrategy in currentProduct)
      {
          for(var currentValue in options())
          {
              returnNewList.add(createStrategy(currentStrategy,currentValue));
          }
      }

      return returnNewList;
   }

   Strategy createStrategy(Strategy oldStrategy,var currentValue)
   {
     Strategy newStrategy = new Strategy();

     newStrategy.stopLoss = oldStrategy.stopLoss;
     newStrategy.window=oldStrategy.window;

     switch(name)
     {
       case "window":
         newStrategy.window=currentValue as int;
         break;
       case "stopLoss":
         newStrategy.stopLoss=currentValue as double;
         break;
     }
     return newStrategy;
   }

}



class Experiment
{

}
