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
import 'forex_prices.dart';
import 'forex_price_control.dart';
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
  bool firstLoad;
  bool sessionSelected;
  Timer countdownSesssions;
  DateTime startDate;
  DateTime endDate;
  TradingSession currentSession;
  List<String> currencyPairs;
  List<ForexDailyValue> dailycurrencies;
  ForexSession.created() : super.created();
  ready()
  {
     sessionSelected=false;
     PaperIconButton navIconMenu = $['navIconMenu'];
     PaperIconButton navIconMenuBack = $['navIconMenuBack'];
     PaperDrawerPanel panel = $['drawerPanel'];

     PaperDialog dialogTrade=$['dialogTrade'];
     PaperDialog dialogCloseTrade=$['dialogCloseTrade'];


     PaperMenu menuPage=$['menuPage'];
     //PaperFab playpauseBtn =$['playpauseBtn'];

     sessions=<Map>[];
     sessionPanel=$['sessionPanel'];


     mainChart=$['mainChart'];
     tradeControl = $['tradeControl'];
     currentSession = new TradingSession();



     navIconMenu.on['tap'].listen((event)=>panel.togglePanel());
     navIconMenuBack.on['tap'].listen((event)=>panel.togglePanel());



     menuPage.on['tap'].listen(menuPageSwitcher);





     panel.forceNarrow=true;
     firstLoad=true;
     set('itemIndex',0);
     UpdateRealTimePrices();
     loadCurrencyPairs();
     getDailyCurrencies();
     loadServerTime();

     const period = const Duration(seconds:10);
     new Timer.periodic(period, (Timer t) async => await UpdateRealTimePrices());
     new Timer.periodic(period, (Timer t) async => await UpdateSessions());
  }

  menuPageSwitcher(var event)
  {
    if(get('itemIndex')==4 && firstLoad)
    {
      loadSessions();
      firstLoad=false;
    }
    //window.alert(get('itemIndex').toString());
    if(get('itemIndex')==1 && !sessionSelected)
    {
      set('itemIndex',0);
    }


    PaperDrawerPanel panel = $['drawerPanel'];
    panel.togglePanel();

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
    if(!currentSessionId.isEmpty)
      SetUpDashboard();
    panel.togglePanel();
  }

  loadCurrencyPairs() async
  {
    var url = "/api/forexclasses/v1/pairs";
    String request = await HttpRequest.getString(url);
    currencyPairs=JSON.decode(request);
    set('currencyPairs',currencyPairs);


    List<String> pairs = ["<ALL>"];
    pairs.addAll(JSON.decode(request));
    sessionPanel.currencyPairs = pairs;

  }

  updatePairs(List<Map> prices)
  {
    ForexPairTable pairTable=$['pairTable'];
    pairTable.currencyPairs=currencyPairs;
    pairTable.prices=prices;
    tradeControl.prices=prices;
  }

  UpdateSessions() async
  {

      for(Map session in sessions)
      {
          if(session["lastUpdatedTime"]!=null && session["lastUpdatedTime"]!="null"
              && session["id"]!="liveSession"
              && session["sessionType"]!="SessionType.live")
          {

            //DateFormat formatter = new DateFormat("yyyyMMddTHHmmss");//('yyyyMMddTHHmmssZ');
            String timestamp = session["lastUpdatedTime"];
            //print(session["id"]+" Updated "+session["lastUpdatedTime"].toString());
            List<Map> ListMapSession = await loadLatestSession(
                session["id"], timestamp);
            if(ListMapSession.length>0)
            {
                session["lastUpdatedTime"]=ListMapSession[0]["lastUpdatedTime"];
                print(session["id"]+" Updated "+session["lastUpdatedTime"].toString());
                sessionPanel.updateSession(new TradingSession.fromJSONMap(ListMapSession[0]));
                PaperToast toastSession=$['toastSession'];
                toastSession.text="${session["id"]} updated";
                toastSession.duration=3000;
                toastSession.open();
            }
          }
      }

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

  Future UpdateRealTimePrices() async
  {

      await loadCurrencyPairs();
      List<Price> currentPrices = <Price>[];
      for(String pair in currencyPairs)
      {
        var url = "/api/forexclasses/v1/latestprices/$pair";
        String priceJson = await HttpRequest.getString(url);

        Price latestPrice = new Price.fromJson(priceJson);

        DateFormat formatter = new DateFormat('yyyyMMdd');
        String currentDate=formatter.format(latestPrice.time);

        String indicator = await GetIndicator("RSIOversold30", pair, currentDate, "14");
        latestPrice.indicator = indicator;
        currentPrices.add(latestPrice);
      }

      ForexPriceControl priceControl = $["priceControl"];
      priceControl.prices=currentPrices;
      await UpdateLiveSession();
  }


  UpdateLiveSession() async
  {
    ForexPriceControl priceControl = $["priceControl"];
    DateFormat formatter = new DateFormat('yyyyMMdd');
    TradingSession session = await loadSession("liveSession");
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

    priceControl.sessionDetail=
      new ForexSessionDetail()
      ..id = session.id
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
      ..pctOpen=pctOpen.toStringAsFixed(2);

    updateTradeMenuLive(session);
  }

  Future<String> GetIndicator(String ruleName,String pair,String date,String window) async
  {
       var url="/api/forexclasses/v1/dailyindicator/$ruleName/$window/$pair/$date";
       String request = await HttpRequest.getString(url);
       return JSON.decode(request)[0].toString();
  }

  Future<TradingSession> loadSession(String id) async
  {
    var url = "/api/forexclasses/v1/getsession/$id";
    String request = await HttpRequest.getString(url);
    return new TradingSession.fromJSON(request);

  }

  Future<List<Map>> loadLatestSession(String id,String timestamp) async
  {
    var url = "/api/forexclasses/v1/getlatestsession/$id/$timestamp";
    String request = await HttpRequest.getString(url);
    return JSON.decode(request);

  }

  deleteSession(String id) async
  {
    var url = "/api/forexclasses/v1/deletesession/$id";
    String request = await HttpRequest.getString(url);
    await loadSessions();
    PaperToast toastSession=$['toastSession'];
    toastSession.text="$id deleted";
    toastSession.duration=3000;
    toastSession.open();
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
    var urlSave = "/api/forexclasses/v1/addsessionpost";//"/api/forexclasses/v1/addsessionpost";
    var urlQueue = "/api/forexclasses/v1/pushtoqueuesessionpost";
    PostData myData = new PostData();


    myData.data=tradeSession.toJson();

    HttpRequest.request(urlSave, method:'POST',
        requestHeaders: {"content-type": "application/json"},
        sendData:myData.toJson());

    HttpRequest.request(urlQueue, method:'POST',
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

    ForexPriceControl priceControl = $["priceControl"];

    mainChart.showCharts();
    mainChart.loadBalanceChart(currentSessionId,balanceHist());
    mainChart.loadTradesHistogram(currentSessionId,TradingHistogram());
    mainChart.loadTradesTimeHistogram(currentSessionId,TradingTimeHistogram());
    mainChart.loadBarChartTradeByPair(currentSessionId, BarChartTradeByPair());
    mainChart.loadBarChartPLByPair(currentSessionId, BarChartPLByPair());
    mainChart.loadBarChartOpenTradeByPair(currentSessionId, BarChartOpenTradesByPair());

    if(firstLoad && currentSessionId=="liveSession")
      mainChart.sessionDetail=priceControl.sessionDetail;
    else
      mainChart.sessionDetail=sessionPanel.GetSession(currentSessionId);


    if(currentSession.sessionUser.AllTradingPairs().length>0)
    {

      DateFormat formatter = new DateFormat('yyyyMMdd');
      String startdt=formatter.format(currentSession.startDate);
      String enddt=formatter.format(currentSession.currentTime);
      String pair = currentSession.sessionUser.AllTradingPairs()[0];
      List values = await dailyValues(pair, startdt, enddt);
      mainChart.loadCurrencyChart(pair,values);
    }

    mainChart.sessionDetail.SpinnerOff();
  }

  SetUpDashboardPair(String pair,DateTime startFilterDate,DateTime endFilterDate) async
  {

    DateFormat formatter = new DateFormat('yyyyMMdd');
    String startdt=formatter.format(currentSession.startDate);
    String enddt=formatter.format(currentSession.currentTime);
    String title = "$currentSessionId Pair: $pair";

    List values = await dailyValues(pair, formatter.format(startFilterDate), formatter.format(endFilterDate));
    List balanceHistPairList = balanceHistPair(pair,startFilterDate,endFilterDate);

    mainChart.showCharts();
    mainChart.loadCurrencyChart(pair,values);
    mainChart.loadBalanceChart( title,balanceHistPairList);
    mainChart.loadTradesHistogram(title ,TradingHistogramPair(pair,startFilterDate,endFilterDate));
    mainChart.loadTradesTimeHistogram(title ,TradingTimeHistogramPair(pair,startFilterDate,endFilterDate));



    var closedTrades = currentSession.sessionUser.closedTrades()
        .where((t)=>t.pair==pair)
        .where((t)=>DateTime.parse(t.closeDate).isAfter(startFilterDate))
        .where((t)=>DateTime.parse(t.closeDate).isBefore(endFilterDate))
        .length;

    var pct =closedTrades==0? 0 : currentSession.sessionUser.closedTrades()
        .where((t)=>t.pair==pair)
        .where((t)=>DateTime.parse(t.closeDate).isAfter(startFilterDate))
        .where((t)=>DateTime.parse(t.closeDate).isBefore(endFilterDate))
        .where((x)=>x.PL()>0).length.toDouble() / closedTrades.toDouble() ;
    pct = pct * 100;

    var openTrades = currentSession.sessionUser.openTrades()
        .where((t)=>t.pair==pair)
        .length;

    var pctOpen =openTrades==0? 0 : currentSession.sessionUser.openTrades()
        .where((t)=>t.pair==pair)
        .where((x)=>x.PL()>0).length.toDouble() / openTrades.toDouble() ;
    pctOpen = pctOpen * 100;

    var balance =balanceHistPairList.length==0 ? 0: balanceHistPairList.last[1];
    var pl = balanceHistPairList.length==0 ? 0:(balance - balanceHistPairList.first[1]);

    mainChart.sessionDetail= new ForexSessionDetail()
      ..id = title
      ..startDate=formatter.format(startFilterDate)
      ..currentDate=formatter.format(endFilterDate)
      ..balance = balance.toStringAsFixed(2)
      ..currencyPairs=sessionPanel.currencyPairs
      ..pl = pl.toStringAsFixed(2)
      ..closedTrades=closedTrades.toString()
      ..openTrades=openTrades.toString()
      ..pct= pct.toStringAsFixed(2)
      ..pctOpen=pctOpen.toStringAsFixed(2)
      ..ruleName=currentSession.strategy.ruleName
      ..window=currentSession.strategy.window.toString()
    ;

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

  List balanceHistPair(String pair,DateTime startFilterDate,DateTime endFilterDate)
  {
     DateFormat formatter = new DateFormat('yyyyMMdd');
     List pairBalanceHistory = [];
     findClosedTrades(DateTime date)
     {
        return currentSession
               .sessionUser
               .closedTrades()
               .where((trade)=>trade.pair==pair)
               .where((trade)=>formatter.format(DateTime.parse(trade.closeDate))==formatter.format(date));
     }

     var sessionDates = currentSession
                        .sessionUser
                        .primaryAccount
                        .balanceHistory
                        .map((dailyVal)=>DateTime.parse(dailyVal["date"]))
                        .where((dailyVal)=>dailyVal.isAfter(startFilterDate))
                        .where((dailyVal)=>dailyVal.isBefore(endFilterDate));

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


  List BarChartTradeByPair()
  {
    return currencyPairs.map((pair)=>[pair,
        currentSession
        .sessionUser
        .primaryAccount
        .closedTrades
        .where((trade)=>trade.pair==pair)
        .length
    ]).toList();
  }

  List BarChartOpenTradesByPair()
  {
    return currencyPairs.map((pair)=>[pair,
    currentSession
        .sessionUser
        .openTrades()
        .where((trade)=>trade.pair==pair)
        .length
    ]).toList();
  }

  List BarChartPLByPair()
  {

    Set pairSet =new Set.from(currentSession
        .sessionUser
        .primaryAccount
        .closedTrades
        .map((trade)=>trade.pair)
        .toList()..sort());

    return pairSet.toList().map((pair)=>[pair,
    currentSession
        .sessionUser
        .primaryAccount
        .closedTrades
        .where((trade)=>trade.pair==pair)
        .map((trade)=>trade.PL())
        .reduce((x,y)=>x+y)
    ]).toList();
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

  List TradingHistogramPair(String pair,DateTime startFilterDate,DateTime endFilterDate)
  {
    return currentSession
        .sessionUser
        .primaryAccount
        .closedTrades
        .where((trade)=>trade.pair==pair)
        .where((trade)=>DateTime.parse(trade.closeDate).isAfter(startFilterDate))
        .where((trade)=>DateTime.parse(trade.closeDate).isBefore(endFilterDate))
        .map((trade)=>[trade.pair+trade.openDate,trade.PL()])
        .toList();
  }

  List TradingTimeHistogram()
  {
    int DateDiff(Trade trade)
    {
      DateTime openDate = DateTime.parse(trade.openDate);
      DateTime closeDate = DateTime.parse(trade.closeDate);
      return closeDate.difference(openDate).inDays+1;
    }
    return currentSession
        .sessionUser
        .primaryAccount
        .closedTrades
        .map((trade)=>[trade.pair+trade.openDate,DateDiff(trade)])
        .toList();
  }

  List TradingTimeHistogramPair(String pair,DateTime startFilterDate,DateTime endFilterDate)
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
        .where((trade)=>DateTime.parse(trade.closeDate).isAfter(startFilterDate))
        .where((trade)=>DateTime.parse(trade.closeDate).isBefore(endFilterDate))
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
    ForexPriceControl priceControl = $["priceControl"];
    currentSessionId = detail["id"];
    set('currentSessionId',currentSessionId);

    currentSession = await loadSession(currentSessionId);
    updateSessionCards();
    updateTradeMenu();
    UpdatePrices();

    if(currentSessionId=="liveSession")
    {
      mainChart.sessionDetail= priceControl.sessionDetail;
      mainChart.sessionDetail.currencyPairs=sessionPanel.currencyPairs;
      mainChart.hideCharts();
    }
    else
    {
      mainChart.sessionDetail = sessionPanel.GetSession(currentSessionId);
      mainChart.hideCharts();
    }
    sessionSelected=true;
    //SetUpDashboard();

  }

  void updateTradeMenu()
  {
    updateTradeMenuLive(currentSession);
  }

  void updateTradeMenuLive(TradingSession session)
  {
    if(currentSession.id==session.id)
      tradeControl.updateTrades( session.openTrades("primary"));
  }

  @Listen('savesession')
  void saveSessionEvent(event, detail)
  {
    tradeSession = new TradingSession.fromJSONMap(detail["session"]);
    SaveSession();
  }

  @Listen('deletesession')
  OnDeleteSessionEvent(event, detail) async
  {
    await deleteSession(detail["id"]);
  }

  @Listen('selectfiltersession')
  OnSelectFilterSession(event, detail) async
  {
      if(detail["pair"]=="<ALL>") {
        await SetUpDashboard();
      }
      else
      {
        await SetUpDashboardPair(
            detail["pair"], DateTime.parse(detail["startFilterDate"]),
            DateTime.parse(detail["endFilterDate"]).add(new Duration(days:1)));
      }
  }

}