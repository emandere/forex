@HtmlImport('forex_price_control.html')
library forex.lib.forex_price_control;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
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

  setDivPrices(List<Price> prices)
  {
    DivElement divcurrprices=$['divcurrprices'];
    if(prices.length>0)
    {
      divcurrprices.children.clear();
      for(Price priceVal in prices)
      {
        DivElement divPrice = new DivElement();
        divPrice.text =  priceVal.instrument+": "+ priceVal.ask.toString()+": "+priceVal.time.toIso8601String();
        divcurrprices.children.add(divPrice);
      }
    }
  }
  ForexPriceControl.created() : super.created();
  factory ForexPriceControl() => new Element.tag('forex-price-control') as ForexPriceControl;
  ready()
  {

  }

}
