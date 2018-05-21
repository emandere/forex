@HtmlImport('forex_session_panel.html')
library forex.lib.forex_session_panel;

import 'dart:html';
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
import 'package:polymer_elements/paper_dropdown_menu.dart';

@PolymerRegister('forex-session-panel')
class ForexSessionPanel extends PolymerElement {
  List<Map> _sessions;
  List<String> _currencyPairs=[];
  List<String> _rules = [];
  @property List<String> get currencyPairs => _currencyPairs;
  @reflectable set currencyPairs(List<String> value)
  {
    _currencyPairs=value;
  }

  @property List<String> get rules => _rules;
  @reflectable set rules(List<String> value)
  {
    _rules=value;
    set('rules',_rules);
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
    PaperButton btnCreateStrategy = $['btnCreateStrategy'];
    PaperButton btnCreateSession = $['btnCreateSession'];
    PaperButton btnAddStrategy = $['btnAddStrategy'];
    PaperDialog dialogSession = $['dialogSession'];
    PaperDialog dialogStrategy = $['dialogStrategy'];

    menuSession.on['iron-select'].listen(sendSelectedSession);
    btnAddSession.on['tap'].listen((event) => dialogSession.open());
    btnAddStrategy.on['tap'].listen((event) => dialogStrategy.open());

    btnCreateStrategy.on['tap'].listen((event) => dialogStrategy.open());
    btnCreateSession.on['tap'].listen(sendUserSession);
  }

  void sendSelectedSession(var event) {
    this.fire('selectsession', detail: {"session":$['menuSession'].selected});
  }

  void sendUserSession(var event) {
    PaperInput sessionId = $['sessionId'];
    PaperInput startDate = $['startDate'];
    PaperInput endDate = $['endDate'];
    PaperInput primaryAmount = $['primaryAmount'];
    PaperInput secondaryAmount = $['secondaryAmount'];
    PaperInput position = $['position'];
    PaperDropdownMenu rule = $['rule'];
    PaperInput pwindow = $['window'];
    PaperInput units = $['units'];
    PaperInput stopLoss = $['stopLoss'];
    PaperInput takeProfit = $['takeProfit'];
    PaperDropdownMenu sessionTypeMenu = $['sessionTypeMenu'];


    TradingSession tradeSession = new TradingSession();
    tradeSession.id = sessionId.value;
    tradeSession.sessionUser.id = "testSessionUser";
    tradeSession.startDate = DateTime.parse(startDate.value);
    tradeSession.endDate = DateTime.parse(endDate.value);
    tradeSession.currentTime = DateTime.parse(startDate.value);

    String sessionTypeValue=sessionTypeMenu.value;
    if(sessionTypeMenu.value==null)
      sessionTypeValue=sessionTypeMenu.placeholder;

    String ruleTypeValue=rule.value;
    if(rule.value==null)
      ruleTypeValue=rule.placeholder;

    tradeSession.sessionType=SessionType.values.firstWhere((x)=>x.toString()=="SessionType.${sessionTypeValue}");

    tradeSession.fundAccount("primary", double.parse(primaryAmount.value));
    tradeSession.fundAccount("secondary", double.parse(secondaryAmount.value));

    tradeSession.strategy.ruleName=ruleTypeValue;
    tradeSession.strategy.window=pwindow.value;
    tradeSession.strategy.units=units.value;
    tradeSession.strategy.stopLoss=stopLoss.value;
    tradeSession.strategy.takeProfit=takeProfit.value;
    tradeSession.strategy.position=position.value;


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
      var pct = closedTrades==0?0:session.sessionUser.closedTrades()
                                                      .where((x)=>x.PL()>0)
                                                      .length.toDouble() / closedTrades.toDouble() ;
      pct = pct * 100;

      var openTrades = session.sessionUser.openTrades().length;
      var pctOpen = openTrades==0?0:session.sessionUser.openTrades()
          .where((x)=>x.PL()>0)
          .length.toDouble() / openTrades.toDouble() ;
      pctOpen = pctOpen * 100;
      
      menuSession.children.add(new ForexSessionDetail()
        ..id = session.id
        ..sessionProgress=session.percentComplete.toString()
        ..startDate=formatter.format(session.startDate)
        ..currentDate=formatter.format(session.currentTime)
        ..balance = session.balance().toStringAsFixed(2)
        ..currencyPairs=currencyPairs
        ..pl = session.PL().toStringAsFixed(2)
        ..closedTrades=closedTrades.toString()
        ..openTrades=openTrades.toString()
        ..ruleName=session.strategy.ruleName
        ..window=session.strategy.window.toString()
        ..stopLoss=session.strategy.stopLoss.toString()
        ..takeProfit=session.strategy.takeProfit.toString()
        ..units=session.strategy.units.toString()
        ..position=session.strategy.position
        ..pct= pct.toStringAsFixed(2)
        ..pctOpen=pctOpen.toStringAsFixed(2)  
      );

    }
  }

  updateSession(TradingSession session)
  {
    DateFormat formatter = new DateFormat('yyyyMMdd');
    PaperMenu menuSession = $['menuSession'];
    ForexSessionDetail sessionCard = menuSession.children.firstWhere((x)=>x.id==session.id);

    var closedTrades = session.sessionUser.closedTrades().length;
    var pct = closedTrades==0?0:session.sessionUser.closedTrades()
        .where((x)=>x.PL()>0)
        .length.toDouble() / closedTrades.toDouble() ;
    pct = pct * 100;

    var openTrades = session.sessionUser.openTrades().length;
    var pctOpen = openTrades==0?0:session.sessionUser.openTrades()
        .where((x)=>x.PL()>0)
        .length.toDouble() / openTrades.toDouble() ;
    pctOpen = pctOpen * 100;

    sessionCard.id=session.id;
    sessionCard.sessionProgress=session.percentComplete.toString();
    sessionCard.startDate=formatter.format(session.startDate);
    sessionCard.currentDate=formatter.format(session.currentTime);
    sessionCard.balance=session.balance().toStringAsFixed(2);
    sessionCard.pl=session.PL().toStringAsFixed(2);
    sessionCard.closedTrades=closedTrades.toString();
    sessionCard.openTrades=openTrades.toString();
    sessionCard.pct=pct.toStringAsFixed(2);
    sessionCard.pctOpen=pctOpen.toStringAsFixed(2);


    sessionCard.ruleName=session.strategy.ruleName;
    sessionCard.window=session.strategy.window.toString();
    sessionCard.stopLoss=session.strategy.stopLoss.toString();
    sessionCard.takeProfit=session.strategy.takeProfit.toString();
    sessionCard.units=session.strategy.units.toString();
    sessionCard.position=session.strategy.position;

  }

  UpdateDialogSession(TradingSession session)
  {

    PaperInput startDate = $['startDate'];
    PaperInput endDate = $['endDate'];
    PaperInput primaryAmount = $['primaryAmount'];
    PaperInput secondaryAmount = $['secondaryAmount'];
    PaperInput position = $['position'];
    PaperDropdownMenu rule = $['rule'];
    PaperInput window = $['window'];
    PaperInput units = $['units'];
    PaperInput stopLoss = $['stopLoss'];
    PaperInput takeProfit = $['takeProfit'];
    PaperDropdownMenu sessionTypeMenu = $['sessionTypeMenu'];

    DateFormat formatter = new DateFormat('yyyyMMdd');

    startDate.value=formatter.format(session.startDate);
    endDate.value=formatter.format(session.endDate);
    rule.placeholder=session.strategy.ruleName;
    rule.selectedItem=session.strategy.ruleName;
    sessionTypeMenu.placeholder="test";
    sessionTypeMenu.selectedItem="test";
    primaryAmount.value=session.sessionUser.secondaryAccount.cash.toString();
    secondaryAmount.value=session.sessionUser.secondaryAccount.cash.toString();
    
    position.value=session.strategy.position;
    window.value=session.strategy.window.toString();
    units.value=session.strategy.units.toString();
    stopLoss.value=session.strategy.stopLoss.toStringAsFixed(3);
    takeProfit.value=session.strategy.takeProfit.toStringAsFixed(3);
    
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