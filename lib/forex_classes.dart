library forex_classes;
import 'dart:convert';
import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import "package:collection/collection.dart";
import 'package:intl/intl.dart';
import 'forex_prices.dart';
import 'forex_indicator_rules.dart';
import 'forex_prices.dart';
import 'forex_stats.dart';
import 'candle_stick.dart';
part 'forexclasses/forex_trade_class.dart';
part 'forexclasses/forex_strategy_class.dart';
part 'forexclasses/forex_order_class.dart';
part 'forexclasses/forex_account_class.dart';
part 'forexclasses/forex_user_class.dart';
part 'forexclasses/forex_tradingsession_class.dart';

class PostData
{
  String data;
  Map toJsonMap()
  {
    return {"data":data};
  }

  String toJson()
  {
    return JSON.encode(toJsonMap());
  }
}






