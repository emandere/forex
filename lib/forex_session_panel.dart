@HtmlImport('forex_session_panel.html')
library forex.lib.forex_session_panel;

import 'forex_classes.dart';
import 'forex_session_detail.dart';
import 'package:polymer/polymer.dart';
import 'package:intl/intl.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_menu.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_dialog.dart';
import 'package:polymer_elements/paper_input.dart';


@PolymerRegister('forex-session-panel')
class ForexSessionPanel extends PolymerElement {
  List<Map> _sessions;
  List<String> _currencyPairs=[];
  @property List<String> get currencyPairs => _currencyPairs;
  @reflectable set currencyPairs(List<String> value)
  {
    _currencyPairs=value;
  }

  @property List<Map> get sessions => _sessions;

  @reflectable set sessions(List<Map> value) {
    _sessions = value;
    set('sessions', _sessions);
    updateSessions();
  }

  ForexSessionPanel.created() : super.created();

  ready() {
    PaperMenu menuSession = $['menuSession'];
    PaperButton btnAddSession = $['btnAddSession'];
    PaperButton btnCreateSession = $['btnCreateSession'];
    PaperDialog dialogSession = $['dialogSession'];

    menuSession.on['iron-select'].listen(sendSelectedSession);
    btnAddSession.on['tap'].listen((event) => dialogSession.open());
    btnCreateSession.on['tap'].listen(sendUserSession);
  }

  void sendSelectedSession(var event) {
    this.fire('selectsession', detail: {"session":$['menuSession'].selected});
  }

  void sendUserSession(var event) {
    PaperInput sessionId = $['sessionId'];
    PaperInput startDate = $['startDate'];
    PaperInput primaryAmount = $['primaryAmount'];
    PaperInput secondaryAmount = $['secondaryAmount'];


    TradingSession tradeSession = new TradingSession();
    tradeSession.id = sessionId.value;
    tradeSession.sessionUser.id = "testSessionUser";
    tradeSession.startDate = DateTime.parse(startDate.value);
    tradeSession.currentTime = DateTime.parse(startDate.value);
    tradeSession.fundAccount("primary", double.parse(primaryAmount.value));
    tradeSession.fundAccount("secondary", double.parse(secondaryAmount.value));

    this.fire('savesession', detail: {"session":tradeSession.toJsonMap()});

    //SaveSession();
  }

  updateSessions()
  {
    PaperMenu menuSession = $['menuSession'];
    DateFormat formatter = new DateFormat('yyyyMMdd');
    menuSession.children.clear();
    for (Map mapSession in sessions)
    {
      TradingSession session = new TradingSession.fromJSONMap(mapSession);
      var closedTrades = session.sessionUser.closedTrades().length;
      var pct = session.sessionUser.closedTrades().where((x)=>x.PL()>0).length.toDouble() / closedTrades.toDouble() ;
      pct = pct * 100;
      menuSession.children.add(new ForexSessionDetail()
        ..id = session.id
        ..startDate=formatter.format(session.startDate)
        ..currentDate=formatter.format(session.currentTime)
        ..balance = session.balance().toStringAsFixed(2)
        ..currencyPairs=currencyPairs
        ..pl = session.PL().toStringAsFixed(2)
        ..closedTrades=closedTrades.toString()
        ..pct= pct.toStringAsFixed(2));

    }
  }

  updateSession(TradingSession session)
  {
    DateFormat formatter = new DateFormat('yyyyMMdd');
    PaperMenu menuSession = $['menuSession'];
    ForexSessionDetail sessionCard = menuSession.children.firstWhere((x)=>x.id==session.id);
    sessionCard.id=session.id;
    sessionCard.startDate=formatter.format(session.startDate);
    sessionCard.currentDate=formatter.format(session.currentTime);
    sessionCard.balance=session.balance().toStringAsFixed(2);
    sessionCard.pl=session.PL().toStringAsFixed(2);
  }

  ForexSessionDetail GetSession(String id)
  {
    PaperMenu menuSession = $['menuSession'];
    return menuSession.children.firstWhere((sessionCard)=>(sessionCard as ForexSessionDetail).id==id);
  }

  uncheckUnselectedSessions(String id)
  {
    PaperMenu menuSession = $['menuSession'];
    for(ForexSessionDetail sessionCard in menuSession.children)
    {
      if(sessionCard.id!=id)
        sessionCard.clearSelection();
    }
  }
}