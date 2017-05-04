@HtmlImport('forex_price_control.html')
library forex.lib.forex_price_control;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
@PolymerRegister('forex-price-control')
class ForexPriceControl extends PolymerElement
{
  List<Map> _prices;
  @property List<Map> get prices => _prices;
  @reflectable set prices(List<Map> value)
  {
    _prices = value;
  }
  ForexPriceControl.created() : super.created();
  factory ForexPriceControl() => new Element.tag('forex-price-control') as ForexPriceControl;
  ready()
  {

  }

}
