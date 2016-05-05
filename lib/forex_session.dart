@HtmlImport('forex_session.html')
library forex.lib.forex_session;
import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'forex_session_main_chart.dart';
import 'forex_classes.dart';
import 'candle_stick.dart';
import 'package:intl/intl.dart';
import 'forex_pair.dart';
import 'forex_pair_header.dart';

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
  @property
  String avicon;
  @property
  int itemIndex;
  @property
  List<String> sessions;
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


     PaperDialog dialogSession=$['dialogSession'];
     PaperDialog dialogTrade=$['dialogTrade'];
     PaperDialog dialogCloseTrade=$['dialogCloseTrade'];

     PaperButton btnCreateSession=$['btnCreateSession'];
     PaperButton btndialogOpenTrade=$['btndialogOpenTrade'];

     PaperButton btnAddSession=$['btnAddSession'];
     PaperButton btnCreateTrade=$['btnCreateTrade'];
     PaperButton btnCloseTrade=$['btnCloseTrade'];

     PaperItem sessionItem=$['sessionItem'];
     PaperMenu menuPage=$['menuPage'];
     PaperFab playpauseBtn =$['playpauseBtn'];
     PaperMenu menuSession=$['menuSession'];

     currentSession = new TradingSession();
     mainChart=$['mainChart'];

     btndialogOpenTrade.on['tap'].listen((event){pause();dialogTrade.open();});
     btnAddSession.on['tap'].listen((event)=>dialogSession.open());
     navIconMenu.on['tap'].listen((event)=>panel.togglePanel());
     navIconMenuBack.on['tap'].listen((event)=>panel.togglePanel());



     btnCreateSession.on['tap'].listen(CreateUserSession);
     btnCreateTrade.on['tap'].listen(CreateTrade);
     btnCloseTrade.on['tap'].listen(CloseTrade);
     menuPage.on['tap'].listen((event)=>panel.togglePanel());
     playpauseBtn.on['tap'].listen((event)=>playpause());
     menuSession.on['iron-select'].listen(UpdateCurrentSession);

     countdownAmt=1;



     panel.forceNarrow=true;
     set('itemIndex',0);

     loadSessions();
     loadCurrencyPairs();
     getDailyCurrencies();
     pause();
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
    DivElement divpaircards=$['divpaircards'];
    String move;
    //String moveicon;
    //ForexPair pair = new ForexPair.created();
    if(prices.length>0)
    {
      divpaircards.children.clear();
      divpaircards.children.add(new ForexPairHeader());
      for (String pair in currencyPairs)
      {
        Map data=prices.firstWhere((Map i)=>i["pair"]==pair);
        if(data["open"]<data["close"])
        {
          move="up";
          //moveicon="icons:arrow-upward";
        }
        else
        {
          move="down";
          //moveicon="icons:arrow-downward";
        }
        divpaircards.children.add(new ForexPair()
          ..pair = pair
          ..move=move
          //..moveicon=moveicon
          ..open=padzeros(data["open"].toString())
          ..high=padzeros(data["high"].toString())
          ..low=padzeros(data["low"].toString())
          ..close=padzeros(data["close"].toString()));


        ;
      }
    }
  }

  padzeros(String str)
  {
     for(int i=str.length;i<=5;i++)
     {
        str=str+"0";
     }
     return str;
  }


  UpdateCurrentSession(Event e) async
  {
     currentSessionId=sessions[$['menuSession'].selected];
     set('currentSessionId',currentSessionId);
     currentSession = await loadSession(currentSessionId);
     updateTradeMenu();
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
    var url = "/api/forexclasses/v1/sessions";
    String request = await HttpRequest.getString(url);
    sessions=JSON.decode(request);
    set('sessions',sessions );
  }

  CreateTrade(Event e)
  {
    PaperInput account=$['primaryTradeAccount'];
    PaperInput pair=$['pair'];
    PaperInput units=$['units'];
    PaperInput position=$['position'];
    PaperInput stopLoss=$['stopLoss'];
    PaperInput takeProfit=$['takeProfit'];

    currentSession.executeTrade(account.value,pair.value,int.parse(units.value),position.value,currentSession.currentTime.toString());

    int lastTrade = currentSession.sessionUser.Accounts[account.value].idcount-1;
    double stopLossPrice = double.parse(stopLoss.value);
    double takeProfitPrice = double.parse(takeProfit.value);
    //window.alert(lastTrade.toString()+" "+currentSession.sessionUser.Accounts[account.value].Trades[0].id.toString());
    if(position.value=="long")
    {
       currentSession.setOrder(account.value,lastTrade,stopLossPrice,false);
       currentSession.setOrder(account.value,lastTrade,takeProfitPrice,true);
       //window.alert(currentSession.sessionUser.Accounts[account.value].orders.length.toString());
    }
    else
    {
      currentSession.setOrder(account.value,lastTrade,stopLossPrice,true);
      currentSession.setOrder(account.value,lastTrade,takeProfitPrice,false);
    }




    updateTradeMenu();
    play();
  }
  CloseTrade(Event e)
  {
     PaperMenu menuTrades =$['menuTrades'];
     int index = menuTrades.selected;
     //window.alert(index.toString());
     if (index !=null && currentSession.sessionUser.primaryAccount.Trades.length > 0 && index>=0)
     {
       int id=currentSession.sessionUser.primaryAccount.Trades[index].id;
       currentSession.closeTrade("primary", id);
       menuTrades.selected=null;
     }
     updateTradeMenu();
     //window.alert(index.toString());
  }

  void updateTradeMenu()
  {
    DateFormat formatter = new DateFormat('yyyyMMdd');
    trades=new List<String>();
    for(Trade sessTrade in currentSession.openTrades("primary"))
    {
      //if(openPrice!=null && closePrice!=null)
      //{
       trades.add(sessTrade.pair
             +" "+formatter.format(DateTime.parse(sessTrade.openDate))
             +" "+formatter.format(DateTime.parse(sessTrade.closeDate))
             +" "+sessTrade.units.toString()
             +" "+sessTrade.openPrice.toString()
             +" "+sessTrade.closePrice.toString()
             +" "+sessTrade.PL().toString()
       );
    }
    set('trades',trades);
  }

  CreateUserSession(Event e)
  {
      PaperInput sessionId=$['sessionId'];
      PaperInput startDate=$['startDate'];
      PaperInput primaryAmount=  $['primaryAmount'] ;
      PaperInput secondaryAmount=  $['secondaryAmount'] ;


      tradeSession = new TradingSession();
      tradeSession.id=sessionId.value;
      tradeSession.sessionUser.id="testSessionUser";
      tradeSession.startDate=DateTime.parse(startDate.value);
      tradeSession.currentTime=DateTime.parse(startDate.value);
      tradeSession.fundAccount("primary",double.parse(primaryAmount.value));
      tradeSession.fundAccount("secondary",double.parse(secondaryAmount.value));

      SaveSession();
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


  playpause()
  {
    if(playState)
      pause();
    else
      play();
  }

  pause()
  {
    if(countdownSesssions!=null && countdownSesssions.isActive)
    {
      countdownSesssions.cancel();
    }
    playState=false;
    set('avicon','av:play-circle-outline');
  }

  play()
  {
    countdownSesssions = new Timer.periodic(durationCountdown,updateCountdown);
    playState = true;
    set('avicon','av:pause-circle-outline');
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

  updateCountdown(Timer e) async
  {
    countdownAmt=countdownAmt-1;


    DateFormat formatter = new DateFormat('yyyyMMdd');

    String startdt=formatter.format(currentSession.startDate);
    String enddt=formatter.format(currentSession.currentTime);

    if(countdownAmt==0)
    {
      countdownAmt = 5;
      //endDate=endDate.add(new Duration(days: 1));


      await currentSession.updateTime(1,readDailyValue,readDailyValueMissing);
      await currentSession.processOrders(readDailyValue,readDailyValueMissing);
      currentSession.updateHistory();
      updateTradeMenu();
      UpdatePrices();
      mainChart.loadBalanceChart(currentSessionId,balanceHist());
      if(currentSession.sessionUser.TradingPairs().length>0)
      {
        String pair = currentSession.sessionUser.TradingPairs()[0];
        List values = await dailyValues(pair, startdt, enddt);
        mainChart.loadCurrencyChart(pair, startdt, enddt, values);
      }

    }

    set('countdown',countdownAmt.toString());
  }

  List balanceHist()
  {
    var data=new List();
    for(Map dailyVal in currentSession.sessionUser.primaryAccount.balanceHistory)
    {
      var dval = new List();
      dval.add(DateTime.parse(dailyVal["date"]));
      dval.add(dailyVal["amount"]);
      data.add(dval);
    }
    return data;
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

}