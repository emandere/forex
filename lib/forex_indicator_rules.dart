library indicator_library;
import 'dart:math';
import 'forex_stats.dart';
part 'indicators/AboveBollingerBandHigher.dart';
part 'indicators/RandomRule.dart';
part 'indicators/PositiveSlopeAndGreaterThanAverage.dart';
part 'indicators/BelowBollingerBandLower.dart';
part 'indicators/BelowBollingerBandLowerWithSlope.dart';

abstract class IndicatorRule
{
  factory IndicatorRule(String ruleName,int dataPoints)
  {
      switch(ruleName)
      {
        case "AboveBollingerBandHigher":
          return new AboveBollingerBandHigher(ruleName,dataPoints);
        case "RandomRule":
          return new RandomRule(ruleName,dataPoints);
        case "BelowBollingerBandLowerWithSlope":
          return new BelowBollingerBandLowerWithSlope(ruleName,dataPoints);
        case "BelowBollingerBandLower":
          return new BelowBollingerBandLower(ruleName,dataPoints);
        case "PositiveSlopeAndGreaterThanAverage":
          return new PositiveSlopeAndGreaterThanAverage(ruleName,dataPoints);
        default:
          throw "Invalid Rule Name";
      }
  }
  String name;
  int dataPoints;
  bool IsMet(Iterable<Map> window,Map currentValue);
}


