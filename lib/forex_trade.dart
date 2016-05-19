@HtmlImport('forex_trade.html')
library forex.lib.forex_trade;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_menu.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_dialog.dart';
@PolymerRegister('forex-trade-control')
class ForexTradeControl extends PolymerElement
{
  String _pair;
  @property String get pair => _pair;
  @reflectable set pair(String value) =>_pair=value;

  ForexTradeControl.created() : super.created();
  ready()
  {
    PaperDialog dialogTrade=$['dialogTrade'];
    PaperButton btndialogOpenTrade=$['btndialogOpenTrade'];
    btndialogOpenTrade.on['tap'].listen((event)=>dialogTrade.open());
  }

  void SetPair(String value)
  {
     pair=value;
     PaperInput txtPair = $['pair'];
     txtPair.value=value;
  }

}