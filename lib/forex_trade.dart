@HtmlImport('forex_trade.html')
library forex.lib.forex_trade;
import 'dart:html';
import 'forex_trade_detail.dart';
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
    PaperButton btnCreateTrade=$['btnCreateTrade'];
    btndialogOpenTrade.on['tap'].listen((event)=>dialogTrade.open());
    btnCreateTrade.on['tap'].listen(sendExecuteTrade);
  }

  void SetPair(String value)
  {
     pair=value;
     PaperInput txtPair = $['pair'];
     txtPair.value=value;
  }

  void sendExecuteTrade(var event)
  {
    PaperInput txtPrimaryTradeAccount=$['primaryTradeAccount'];
    PaperInput txtPair=$['pair'];
    PaperInput txtUnits=$['units'];
    PaperInput txtPosition=$['position'];
    PaperInput txtStopLoss=$['stopLoss'];
    PaperInput txtTakeProfit=$['takeProfit'];


    String account=txtPrimaryTradeAccount.value;
    pair=txtPair.value;
    String units=txtUnits.value;
    String position=txtPosition.value;
    String stopLoss=txtStopLoss.value;
    String takeProfit=txtTakeProfit.value;

    this.fire('executetrade',detail: {"account":account,"pair":pair,"units":units,"position":position,"stopLoss":stopLoss,"takeProfit":takeProfit});
  }

}