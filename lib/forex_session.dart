@HtmlImport('forex_session.html')
library forex.lib.forex_session;
import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'forex_session_main_chart.dart';
import 'forex_classes.dart';
import 'candle_stick.dart';
import 'package:intl/intl.dart';
import 'forex_pair_table.dart';
import 'forex_session_panel.dart';
import 'forex_trade.dart';
import 'forex_session_detail.dart';
import 'package:intl/intl.dart';

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:forex/forex_session_main_chart.dart';
import 'package:polymer_elements/google_chart.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_menu.dart';
import 'package:polymer_elements/paper_dialog.dart';
import 'package:polymer_elements/paper_fab.dart';
import 'package:polymer_elements/iron_icons.dart';
import 'package:polymer_elements/iron_pages.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/paper_drawer_panel.dart';
import 'package:polymer_elements/paper_icon_button.dart';
import 'package:polymer_elements/paper_header_panel.dart';
import 'package:polymer_elements/paper_toolbar.dart';
import 'package:polymer_elements/paper_toast.dart';
import 'package:polymer_elements/paper_listbox.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/iron_iconset.dart';
import 'package:polymer_elements/av_icons.dart';
import 'package:polymer_elements/paper_icon_item.dart';

@PolymerRegister('forex-session')
class ForexSession extends PolymerElement
{
  TradingSession tradeSession;
  ForexMainChart mainChart;
  ForexTradeControl tradeControl;
  ForexSessionPanel sessionPanel;
  @property
  String avicon;
  @property
  int itemIndex;
  @property
  List<Map> sessions;
  List<String> trades;
  String loadingStatus;
  String countdown;
  String currentSessionId;
  int countdownAmt;
  bool playState;
  Timer countdownSesssions;
  DateTime startDate;
  DateTime endDate;
  TradingSession currentSession;
  List<String> currencyPairs;
  List<ForexDailyValue> dailycurrencies;
  ForexSession.created() : super.created();
  ready()
  {

     PaperIconButton navIconMenu = $['navIconMenu'];
     PaperIconButton navIconMenuBack = $['navIconMenuBack'];
     PaperDrawerPanel panel = $['drawerPanel'];

     PaperDialog dialogTrade=$['dialogTrade'];
     PaperDialog dialogCloseTrade=$['dialogCloseTrade'];


     PaperMenu menuPage=$['menuPage'];
     //PaperFab playpauseBtn =$['playpauseBtn'];


     sessionPanel=$['sessionPanel'];


     mainChart=$['mainChart'];
     tradeControl = $['tradeControl'];
     currentSession = new TradingSession();



     navIconMenu.on['tap'].listen((event)=>panel.togglePanel());
     navIconMenuBack.on['tap'].listen((event)=>panel.togglePanel());


     //btnCreateTrade.on['tap'].listen(CreateTrade);

     //menuPage.on['tap'].listen((event)=>panel.togglePanel());
     menuPage.on['tap'].listen(redrawCharts);
     //playpauseBtn.on['tap'].listen((event)=>playpause());




     panel.forceNarrow=true;
     set('itemIndex',0);

     loadSessions();
     loadCurrencyPairs();
     getDailyCurrencies();
     loadServerTime();
  }

  loadServerTime() async
  {
    final DateFormat formatter = new DateFormat('M/d/y HH:mm:ss');
    var url = "/api/forexclasses/v1/starttime";
    String request = await HttpRequest.getString(url);
    var x = JSON.decode(request);

    set('startTime',formatter.format(DateTime.parse(x['time']).toLocal()));
  }

  redrawCharts(var e)
  {
    PaperDrawerPanel panel = $['drawerPanel'];
    panel.togglePanel();
    if(!currentSessionId.isEmpty)
      SetUpDashboard();
  }

  loadCurrencyPairs() async
  {
    var url = "/api/forexclasses/v1/pairs";
    String request = await HttpRequest.getString(url);
    currencyPairs=JSON.decode(request);
    set('currencyPairs',currencyPairs);
  }

  updatePairs(List<Map> prices)
  {
    ForexPairTable pairTable=$['pairTable'];
    pairTable.currencyPairs=currencyPairs;
    pairTable.prices=prices;
    tradeControl.prices=prices;
  }

  UpdateCurrentSession(Event e) async
  {
     currentSessionId=sessions[$['menuSession'].selected]["id"].toString();
     set('currentSessionId',currentSessionId);
     currentSession = await loadSession(currentSessionId);
     UpdatePrices();
  }

  Future UpdatePrices() async {
    List<Map> prices = await readDailyValueAll(currentSession.currentTime);
    updatePairs(prices);
  }

  Future<TradingSession> loadSession(String id) async
  {
    var url = "/api/forexclasses/v1/getsession/$id";
    String request = await HttpRequest.getString(url);
    return new TradingSession.fromJSON(request);

  }

  loadSessions() async
  {
    var pairUrl = "/api/forexclasses/v1/pairs";
    String pairRequest = await HttpRequest.getString(pairUrl);
    List<String> pairs = ["<ALL>"];
    pairs.addAll(JSON.decode(pairRequest));
    sessionPanel.currencyPairs = pairs;

    var url = "/api/forexclasses/v1/sessions";
    String request = await HttpRequest.getString(url);
    sessions=JSON.decode(request);
    set('sessions',sessions );
    sessionPanel.sessions=sessions;

  }



  updateSessionCards()
  {
      ForexSessionPanel sessionPanel = $['sessionPanel'];
      sessionPanel.uncheckUnselectedSessions(currentSessionId);
  }


  SaveSession()
  {
    var url = "/api/forexclasses/v1/addsessionpost";//"/api/forexclasses/v1/addsessionpost";
    PostData myData = new PostData();


    myData.data=tradeSession.toJson();

    HttpRequest.request(url, method:'POST',
        requestHeaders: {"content-type": "application/json"},
        sendData:myData.toJson());


    PaperToast toastSession=$['toastSession'];
    toastSession.text=tradeSession.id+" created and saved";
    toastSession.duration=3000;
    toastSession.open();
    loadSessions();
  }

  updateSession()
  {
    var url = "/api/forexclasses/v1/addsessionpost";//"/api/forexclasses/v1/addsessionpost";
    PostData myData = new PostData();



    myData.data=currentSession.toJson();

    HttpRequest.request(url, method:'POST',
        requestHeaders: {"content-type": "application/json"},
        sendData:myData.toJson());

    sessionPanel.updateSession(currentSession);
    //loadSessions();
  }






  Future<List> dailyValues(String pair,String startDt,String endDt ) async
  {
    var url = "/api/forexclasses/v1/dailyvaluesrange/$pair/$startDt/$endDt";
    String response = await HttpRequest.getString(url);
    return readResponse(response);
  }

  List getDailyCurrencies()
  {
      dailycurrencies = new List();
      ForexDailyValue val= new ForexDailyValue();
      val.pair="testpair";
      val.open=1.0;
      val.open=1.0;
      val.open=1.0;
      val.close=1.0;
      dailycurrencies.add(val);
      set('dailycurrencies',dailycurrencies);
  }

  List readResponse(String responseText)
  {
    List<ForexDailyValue> dailyVals= new List<ForexDailyValue>();
    List<Map> JsonData = JSON.decode(responseText);
    for(var jsonNode in JsonData)
    {
      ForexDailyValue dailyVal = new ForexDailyValue.fromJson(jsonNode);
      dailyVals.add(dailyVal);
    }
    var data=new List();
    for(ForexDailyValue dailyVal in dailyVals)
    {
      var dval = new List();
      dval.add(DateTime.parse(dailyVal.date));
      dval.add(dailyVal.low);
      dval.add(dailyVal.open);
      dval.add(dailyVal.close);
      dval.add(dailyVal.high);
      data.add(dval);
    }
    return data;
  }

  SetUpDashboard() async
  {
    mainChart.loadBalanceChart(currentSessionId,balanceHist());
    mainChart.loadTradesHistogram(currentSessionId,TradingHistogram());
    mainChart.loadTradesTimeHistogram(currentSessionId,TradingTimeHistogram());

    mainChart.sessionDetail=sessionPanel.GetSession(currentSessionId);


    if(currentSession.sessionUser.TradingPairs().length>0)
    {

      DateFormat formatter = new DateFormat('yyyyMMdd');
      String startdt=formatter.format(currentSession.startDate);
      String enddt=formatter.format(currentSession.currentTime);
      String pair = currentSession.sessionUser.TradingPairs()[0];
      List values = await dailyValues(pair, startdt, enddt);
      mainChart.loadCurrencyChart(pair,values);
    }
  }

  SetUpDashboardPair(String pair) async
  {
    DateFormat formatter = new DateFormat('yyyyMMdd');
    String startdt=formatter.format(currentSession.startDate);
    String enddt=formatter.format(currentSession.currentTime);
    String title = "$currentSessionId Pair: $pair";

    List values = await dailyValues(pair, startdt, enddt);
    List balanceHistPairList = balanceHistPair(pair);

    mainChart.loadCurrencyChart(pair,values);
    mainChart.loadBalanceChart( title,balanceHistPairList);
    mainChart.loadTradesHistogram(title ,TradingHistogramPair(pair));
    mainChart.loadTradesTimeHistogram(title ,TradingTimeHistogramPair(pair));


    var closedTrades = currentSession.sessionUser.closedTrades()
                                                  .where((t)=>t.pair==pair).length;
    var pct = currentSession.sessionUser.closedTrades()
                                        .where((t)=>t.pair==pair)
                                        .where((x)=>x.PL()>0).length.toDouble() / closedTrades.toDouble() ;
    pct = pct * 100;
    var balance = balanceHistPairList.last[1];
    var pl = balance - balanceHistPairList.first[1];

    mainChart.sessionDetail= new ForexSessionDetail()
      ..id = title
      ..startDate=formatter.format(currentSession.startDate)
      ..currentDate=formatter.format(currentSession.currentTime)
      ..balance = balance.toStringAsFixed(2)
      ..currencyPairs=sessionPanel.currencyPairs
      ..pl = pl.toStringAsFixed(2)
      ..closedTrades=closedTrades.toString()
      ..pct= pct.toStringAsFixed(2);

    mainChart.sessionDetail.SpinnerOff();
  }

  List balanceHist()
  {
    return currentSession.
         sessionUser
        .primaryAccount
        .balanceHistory
        .map((dailyVal)=>[DateTime.parse(dailyVal["date"]),dailyVal["amount"]])
        .toList();
  }

  List balanceHistPair(String pair)
  {
     List pairBalanceHistory = [];
     findClosedTrades(DateTime date)
     {
        return currentSession
               .sessionUser
               .closedTrades()
               .where((trade)=>trade.pair==pair)
               .where((trade)=>DateTime.parse(trade.closeDate)==date);
     }

     var sessionDates = currentSession
                        .sessionUser
                        .primaryAccount
                        .balanceHistory
                        .map((dailyVal)=>DateTime.parse(dailyVal["date"]));

     double amount = currentSession
                            .sessionUser
                            .primaryAccount
                            .balanceHistory[0]["amount"];

     for(DateTime sessionDate in sessionDates)
     {
        pairBalanceHistory.add([sessionDate,amount]);
        if(findClosedTrades(sessionDate).isNotEmpty)
        {
          amount += findClosedTrades(sessionDate)
                    .map((trade) => trade.PL())
                    .reduce((t, e) => t + e);
        }
     }

     return pairBalanceHistory;
  }

  List TradingHistogram()
  {
     return currentSession
         .sessionUser
         .primaryAccount
         .closedTrades
         .map((trade)=>[trade.pair+trade.openDate,trade.PL()])
         .toList();
  }

  List TradingHistogramPair(String pair)
  {
    return currentSession
        .sessionUser
        .primaryAccount
        .closedTrades
        .where((trade)=>trade.pair==pair)
        .map((trade)=>[trade.pair+trade.openDate,trade.PL()])
        .toList();
  }

  List TradingTimeHistogram()
  {
    int DateDiff(Trade trade)
    {
      DateTime openDate = DateTime.parse(trade.openDate);
      DateTime closeDate = DateTime.parse(trade.closeDate);
      return closeDate.difference(openDate).inDays;
    }
    return currentSession
        .sessionUser
        .primaryAccount
        .closedTrades
        .map((trade)=>[trade.pair+trade.openDate,DateDiff(trade)])
        .toList();
  }

  List TradingTimeHistogramPair(String pair)
  {
    int DateDiff(Trade trade)
    {
      DateTime openDate = DateTime.parse(trade.openDate);
      DateTime closeDate = DateTime.parse(trade.closeDate);
      return closeDate.difference(openDate).inDays;
    }
    return currentSession
        .sessionUser
        .primaryAccount
        .closedTrades
        .where((trade)=>trade.pair==pair)
        .map((trade)=>[trade.pair+trade.openDate,DateDiff(trade)])
        .toList();
  }

  Future<List<Map>> readDailyValue(String pair,DateTime date) async
  {

    DateFormat formatter = new DateFormat('yyyyMMdd');
    String dt=formatter.format(date);

    var url = "/api/forexclasses/v1/readdailyvalue/$pair/$dt";
    String response = await HttpRequest.getString(url);
    return JSON.decode(response);
  }

  Future<List<Map>> readDailyValueAll(DateTime date) async
  {

    DateFormat formatter = new DateFormat('yyyyMMdd');
    String dt=formatter.format(date);

    var url = "/api/forexclasses/v1/dailyvaluesall/$dt";
    String response = await HttpRequest.getString(url);
    return JSON.decode(response);
  }

  Future<List<Map>> readDailyValueMissing(String pair,DateTime date) async
  {
    DateFormat formatter = new DateFormat('yyyyMMdd');
    String dt=formatter.format(date);

    var url = "/api/forexclasses/v1/readdailyvaluemissing/$pair/$dt";
    String response = await HttpRequest.getString(url);
    return JSON.decode(response);
  }

  Future<List<Map>> readDailyValueMissingAll(DateTime date) async
  {
    DateFormat formatter = new DateFormat('yyyyMMdd');
    String dt=formatter.format(date);

    var url = "/api/forexclasses/v1/readdailyvaluemissingall/$dt";
    String response = await HttpRequest.getString(url);
    return JSON.decode(response);
  }

  @Listen('launchpair')
  void regularTap(event, detail)
  {
    //window.alert("here 1");
    //tradeControl.pair=detail['pair'];
    tradeControl.SetPair(detail['pair']);
    set('itemIndex',3);
  }

  @Listen('selectsession')
  selectedSession(event, detail) async
  {
    //int selected=detail['session'];
    //currentSessionId=sessions[selected]["id"];
    currentSessionId = detail["id"];
    set('currentSessionId',currentSessionId);

    currentSession = await loadSession(currentSessionId);
    updateSessionCards();
    //updateTradeMenu();
    UpdatePrices();

    //SetUpDashboard();

  }

  @Listen('savesession')
  void saveSessionEvent(event, detail)
  {
    tradeSession = new TradingSession.fromJSONMap(detail["session"]);
    SaveSession();
  }

  @Listen('selectfiltersession')
  OnSelectFilterSession(event, detail) async
  {
      if(detail["pair"]=="<ALL>")
        SetUpDashboard();
      else
        SetUpDashboardPair(detail["pair"]);
  }

}