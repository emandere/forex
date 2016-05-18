@HtmlImport('forex_trade.html')
library forex.lib.forex_trade;
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
  ForexTradeControl.created() : super.created();
  ready()
  {
    PaperDialog dialogTrade=$['dialogTrade'];
    PaperButton btndialogOpenTrade=$['btndialogOpenTrade'];
    btndialogOpenTrade.on['tap'].listen((event)=>dialogTrade.open());
  }
}