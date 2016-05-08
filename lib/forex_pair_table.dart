@HtmlImport('forex_pair_table.html')
library forex.lib.forex_pair_table;
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'forex_pair.dart';
import 'forex_pair_header.dart';
import 'dart:html';
@PolymerRegister('forex-pair-table')
class ForexPairTable extends PolymerElement
{
  List<Map> _prices;
  List<String> _currencyPairs;

  @property List<Map> get prices => _prices;
  @reflectable set prices(List<Map> value)
  {
    _prices = value;
    updatePairs(_prices);
  }

  @property List<String> get currencyPairs => _currencyPairs;
  @reflectable set currencyPairs(List<String> value)=>_currencyPairs=value;

  ForexPairTable.created() : super.created();
  ready()
  {

  }

  padzeros(String str)
  {
    for(int i=str.length;i<=5;i++)
    {
      str=str+"0";
    }
    return str;
  }

  updatePairs(List<Map> prices)
  {
    DivElement divpaircards=$['divpaircards'];
    String move;
    if(prices.length>0)
    {
      divpaircards.children.clear();
      divpaircards.children.add(new ForexPairHeader());
      for (String pair in currencyPairs)
      {
        Map data=prices.firstWhere((Map i)=>i["pair"]==pair);
        if(data["open"]<data["close"])
        {
          move="up";

        }
        else
        {
          move="down";
        }
        divpaircards.children.add(new ForexPair()
          ..pair = pair
          ..move=move
          ..open=padzeros(data["open"].toString())
          ..high=padzeros(data["high"].toString())
          ..low=padzeros(data["low"].toString())
          ..close=padzeros(data["close"].toString()));
      }
    }
  }
}