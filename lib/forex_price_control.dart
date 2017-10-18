@HtmlImport('forex_price_control.html')
library forex.lib.forex_price_control;
import 'dart:html';
import 'package:intl/intl.dart';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'candle_stick.dart';
import 'forex_price.dart';
import 'forex_prices.dart';

@PolymerRegister('forex-price-control')
class ForexPriceControl extends PolymerElement
{
  List<Price> _prices;
  @property List<Price> get prices => _prices;
  @reflectable set prices(List<Price> value)
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

  setDivPrices(List<Price> prices)
  {
    final DateFormat formatter = new DateFormat('M/d/y HH:mm:ss');
    DivElement divcurrprices=$['divcurrprices'];
    if(prices.length>0)
    {
      divcurrprices.children.clear();
      for(Price priceVal in prices)
      {
        divcurrprices.children.add(new ForexPrice()
          ..pair=priceVal.instrument
          ..price=padzeros(priceVal.ask.toString())
          ..date=formatter.format(priceVal.time)
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
