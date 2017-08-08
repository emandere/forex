@HtmlImport('forex_price_control.html')
library forex.lib.forex_price_control;
import 'dart:html';
import 'package:intl/intl.dart';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'candle_stick.dart';
import 'forex_price.dart';

@PolymerRegister('forex-price-control')
class ForexPriceControl extends PolymerElement
{
  List<ForexDailyValue> _prices;
  @property List<ForexDailyValue> get prices => _prices;
  @reflectable set prices(List<ForexDailyValue> value)
  {
    _prices = value;
    setDivPrices(value);
  }

  padzeros(String str)
  {
    for(int i=str.length;i<=6;i++)
    {
      str=str+"0";
    }
    return str;
  }

  setDivPrices(List<ForexDailyValue> prices)
  {
    final DateFormat formatter = new DateFormat('M/d/y HH:mm:ss');
    DivElement divcurrprices=$['divcurrprices'];
    if(prices.length>0)
    {
      divcurrprices.children.clear();
      for(ForexDailyValue priceVal in prices)
      {
        divcurrprices.children.add(new ForexPrice()
          ..pair=priceVal.pair
          ..price=padzeros(priceVal.close.toString())
          ..date=formatter.format(priceVal.datetime)
          ..indicator=priceVal.indicator
        );
      }
    }
  }
  ForexPriceControl.created() : super.created();
  factory ForexPriceControl() => new Element.tag('forex-price-control') as ForexPriceControl;
  ready()
  {

  }

}
