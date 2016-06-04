@HtmlImport('forex_trade.html')
library forex.lib.forex_trade;
import 'dart:html';
import 'forex_trade_detail.dart';
import 'forex_classes.dart';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:intl/intl.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_menu.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_dialog.dart';
import 'package:polymer_elements/paper_dropdown_menu.dart';
@PolymerRegister('forex-trade-control')
class ForexTradeControl extends PolymerElement
{
  String _pair;
  String _price;
  List<Map> _prices;
  @property String get pair => _pair;
  @reflectable set pair(String value)
  {
    _pair=value;
    set("pair",pair);
  }

  @property List<Map> get prices => _prices;
  @reflectable set prices(List<Map>  value) =>_prices=value;

  @property String get price => _price;
  @reflectable set price(String value)
  {
    _price=value;
    set("price",price);
  }


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
     Map candle = prices.firstWhere((Map i)=>i['pair']==pair);
     price=candle['close'];
     PaperInput txtPair = $['pair'];
     txtPair.value=value;
  }

  void sendExecuteTrade(var event)
  {

    PaperInput txtPair=$['pair'];
    PaperInput txtUnits=$['units'];
    PaperInput txtStopLoss=$['stopLoss'];
    PaperInput txtTakeProfit=$['takeProfit'];
    PaperDropdownMenu menuAccount=$['primaryTradeAccountMenu'];
    PaperDropdownMenu positionMenu=$['positionMenu'];

    String account=menuAccount.value;
    pair=txtPair.value;
    String units=txtUnits.value;
    String position=positionMenu.value;
    String stopLoss=txtStopLoss.value;
    String takeProfit=txtTakeProfit.value;

    this.fire('executetrade',detail: {"account":account,"pair":pair,"units":units,"position":position,"stopLoss":stopLoss,"takeProfit":takeProfit});
  }

  updateTrades(List<Trade> currentTrades)
  {
    DivElement menuTrades=$['menuTrades'];
    menuTrades.children.clear();
    DateFormat formatter = new DateFormat('yyyyMMdd');
    for(Trade currTrade in currentTrades)
    {
      PaperItem item = new PaperItem();
      ForexTradeDetail detail = new ForexTradeDetail()
        ..pair=currTrade.pair
        ..units=currTrade.units.toString()
        ..currentPrice=currTrade.closePrice.toString()
        ..tradeValue=currTrade.value().toString()
        ..openDate=formatter.format(DateTime.parse(currTrade.openDate))
        ..currentDate=formatter.format(DateTime.parse(currTrade.closeDate))
        ..Id=currTrade.id.toString()
        ..account="primary"
        ..PL=currTrade.PL().toString();
      ;

      item.children.add(detail);
      menuTrades.children.add(item);
    }
  }

}