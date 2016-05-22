@HtmlImport('forex_trade_detail.html')
library forex.lib.forex_trade_detail;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';
import 'package:polymer_elements/iron_iconset.dart';
import 'package:polymer_elements/iron_icon.dart';
import 'package:polymer_elements/paper_icon_button.dart';
@PolymerRegister('forex-trade-detail')
class ForexTradeDetail extends PolymerElement
{
  ForexTradeDetail.created() : super.created();
  factory ForexTradeDetail() => new Element.tag('forex-trade-detail') as ForexTradeDetail;
  ready()
  {

  }
}