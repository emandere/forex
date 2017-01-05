@HtmlImport('forex_trade_detail.html')
library forex.lib.forex_trade_detail;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:intl/intl.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';
import 'package:polymer_elements/iron_iconset.dart';
import 'package:polymer_elements/iron_icon.dart';
import 'package:polymer_elements/paper_icon_button.dart';
@PolymerRegister('forex-trade-detail')
class ForexTradeDetail extends PolymerElement
{
  String _pair;
  String _units;
  String _currentPrice;
  String _tradeValue;
  String _PL;
  String _openDate;
  String _currentDate;
  String _Id;
  String _account;


  @property String get account => _account;
  @reflectable set account(String value)
  {
    _account=value;
  }

  @property String get pair => _pair;
  @reflectable set pair(String value)
  {
    _pair=value;
    set('pair', _pair);
  }

  @property String get Id => _Id;
  @reflectable set Id(String value)
  {
    _Id=value;
  }

  @property String get units => _units;
  @reflectable set units(String value)
  {
    _units=value;
    set('units', _units);
  }

  @property String get currentPrice => _currentPrice;
  @reflectable set currentPrice(String value)
  {
    _currentPrice=value;
    set('currentPrice', _currentPrice);
  }

  @property String get tradeValue => _tradeValue;
  @reflectable set tradeValue(String value)
  {
    _tradeValue=value;
    set('tradeValue', _tradeValue);
  }

  @property String get PL => _PL;
  @reflectable set PL(String value)
  {
    _PL=value;
    set('PL', _PL);
  }

  @property String get openDate => _openDate;
  @reflectable set openDate(String value)
  {
    _openDate=value;
    set('openDate', _openDate);
  }

  @property String get currentDate => _currentDate;
  @reflectable set currentDate(String value)
  {
    _currentDate=value;
    set('currentDate', _currentDate);
  }

  ForexTradeDetail.created() : super.created();
  factory ForexTradeDetail() => new Element.tag('forex-trade-detail') as ForexTradeDetail;
  ready()
  {
    PaperIconButton navCloseTrade=$['navCloseTrade'];
    navCloseTrade.on['tap'].listen(sendCloseTrade);
  }

  sendCloseTrade(var event)
  {

    this.fire('closetrade',detail: {"account":account,"id":Id});
  }

}