@HtmlImport('forex_price_control.html')
library forex.lib.forex_price_control;
import 'dart:html';
import 'package:intl/intl.dart';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'candle_stick.dart';
import 'forex_price.dart';
import 'forex_prices.dart';
import 'forex_session_detail.dart';

@PolymerRegister('forex-price-control')
class ForexPriceControl extends PolymerElement
{
  List<Price> _prices;
  ForexSessionDetail _sessionDetail;
  @property List<Price> get prices => _prices;
  @reflectable set prices(List<Price> value)
  {
    _prices = value;
    setDivPrices(value);
  }

  @property ForexSessionDetail get sessionDetail => _sessionDetail;
  @reflectable set sessionDetail(ForexSessionDetail value)
  {

    _sessionDetail = $['sessionDetail'] as ForexSessionDetail;
    _sessionDetail.hidden=false;
    _sessionDetail..id = value.id
      ..startDate=value.startDate
      ..currentDate=value.currentDate
      ..balance = value.balance
      ..pl = value.pl
      ..currencyPairs=value.currencyPairs
      ..closedTrades=value.closedTrades
      ..ruleName=value.ruleName
      ..window=value.window
      ..stopLoss=value.stopLoss
      ..takeProfit=value.takeProfit
      ..units=value.units
      ..position=value.position
      ..selectSession=true
      ..pct= value.pct
      ..pctOpen=value.pctOpen
      ..openTrades=value.openTrades
    ;

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
          ..bid=padzeros(priceVal.bid.toString())
          ..ask=padzeros(priceVal.ask.toString())
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
    ForexSessionDetail _sess = $['sessionDetail'] as ForexSessionDetail;
    _sess.hidden=true;
  }

}
