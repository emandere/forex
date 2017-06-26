@HtmlImport('forex_price.html')
library forex.lib.forex_price;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';
import 'package:polymer_elements/iron_iconset.dart';
import 'package:polymer_elements/iron_icon.dart';
import 'package:polymer_elements/paper_icon_button.dart';
@PolymerRegister('forex-price')
class ForexPrice extends PolymerElement
{
  String _pair;
  String _price;
  String _date;
  String _indicator;

  @property String get pair => _pair;
  @reflectable set pair(String value)
  {
    _pair=value;
    set('pair', _pair);
  }
  @property String get price => _price;
  @reflectable set price(String value)
  {
    _price=value;
    set('price', _price);
  }
  @property String get date => _date;
  @reflectable set date(String value)
  {
    _date=value;
    set('date', _date);
  }

  @property String get indicator => _indicator;
  @reflectable set indicator(String value)
  {
    _indicator=value;
    set('indicator', _indicator);
  }

  ForexPrice.created() : super.created();
  factory ForexPrice() => new Element.tag('forex-price') as ForexPrice;
  ready()
  {

  }

}