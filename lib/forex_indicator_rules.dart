library indicator_library;
import 'dart:math';
import 'forex_stats.dart';
import 'package:collection/collection.dart';
part 'indicators/AboveBollingerBandHigher.dart';
part 'indicators/RandomRule.dart';
part 'indicators/PositiveSlopeAndGreaterThanAverage.dart';
part 'indicators/BelowBollingerBandLower.dart';
part 'indicators/BelowBollingerBandLowerWithSlope.dart';
part 'indicators/RSIOverbought70.dart';
part 'indicators/RSIOversold30.dart';

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
        case "RSIOverbought70":
          return new RSIOverbought70(ruleName,dataPoints);
        case "RSIOversold30":
          return new RSIOversold30(ruleName,dataPoints);
        default:
          throw "Invalid Rule Name";
      }
  }
  String name;
  int dataPoints;
  bool IsMet(Iterable<Map> window,Map currentValue);
}


