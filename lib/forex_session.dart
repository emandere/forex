@HtmlImport('forex_session.html')
library forex.lib.forex_session;
import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'forex_session_main_chart.dart';
import 'forex_classes.dart';
import 'candle_stick.dart';
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
@PolymerRegister('forex-session')
class ForexSession extends PolymerElement
{
  TradingSession tradeSession;
  ForexMainChart mainChart;
  @property
  int itemIndex;
  @property
  List<String> sessions;

  String loadingStatus;
  String countdown;
  int countdownAmt;
  bool playState;
  Timer countdownSesssions;
  DateTime startDate;
  DateTime endDate;

  ForexSession.created() : super.created();
  ready()
  {
     PaperIconButton navIconMenu = $['navIconMenu'];
     PaperIconButton navIconMenuBack = $['navIconMenuBack'];
     PaperDrawerPanel panel = $['drawerPanel'];
     PaperFab createForexSession=$['createForexSession'];
     PaperDialog dialogSession=$['dialogSession'];
     PaperButton btnCreateSession=$['btnCreateSession'];
     PaperItem sessionItem=$['sessionItem'];
     PaperMenu menuPage=$['menuPage'];
     mainChart=$['mainChart'];
     PaperFab playpauseBtn =$['playpauseBtn'];

     navIconMenu.on['tap'].listen((event)=>panel.togglePanel());
     navIconMenuBack.on['tap'].listen((event)=>panel.togglePanel());
     createForexSession.on['tap'].listen((event)=>dialogSession.open());
     btnCreateSession.on['tap'].listen(CreateUserSession);
     menuPage.on['tap'].listen((event)=>panel.togglePanel());
     playpauseBtn.on['tap'].listen((event)=>playpause());

     startDate=DateTime.parse('20110101');
     endDate=DateTime.parse('20110101');
     countdownAmt=5;

     panel.forceNarrow=true;
     set('itemIndex',0);
      //navIconMenu.onClick.listen((event)=>panel.togglePanel());
     loadSessions();
     pause();
  }

  loadSessions() async
  {
    var url = "/api/forexclasses/v1/sessions";
    String request = await HttpRequest.getString(url);
    set('sessions', JSON.decode(request));

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
    window.alert("PlayPausing!");
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
  }

  play()
  {
    countdownSesssions = new Timer.periodic(durationCountdown,updateCountdown);
    playState = true;
  }

  Future<List> dailyValues(String pair,String startDt,String endDt ) async
  {


    var url = "/api/forexclasses/v1/dailyvaluesrange/$pair/$startDt/$endDt";
    String response = await HttpRequest.getString(url);
    return readResponse(response);
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
    String pair='USDJPY';
    String startdt=formatter.format(startDate);
    String enddt=formatter.format(endDate);

    if(countdownAmt==0)
    {
      countdownAmt = 5;
      endDate=endDate.add(new Duration(days: 1));
      List values = await dailyValues(pair,startdt,enddt);
      mainChart.loadCurrencyChart(pair,startdt,enddt,values);
    }

    set('countdown',countdownAmt.toString());
  }

}