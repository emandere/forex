@HtmlImport('forex_session_main_chart.html')
library forex.lib.forex_session_main_chart;

import 'dart:html';
import 'dart:convert';
import 'candle_stick.dart';
import 'dart:async';
import 'forex_classes.dart';
import 'package:intl/intl.dart';

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_elements/google_chart.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_menu.dart';
import 'package:polymer_elements/paper_dialog.dart';
import 'package:polymer_elements/paper_fab.dart';
import 'package:polymer_elements/iron_icons.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/paper_drawer_panel.dart';
import 'package:polymer_elements/paper_header_panel.dart';
import 'package:polymer_elements/paper_toolbar.dart';
import 'package:polymer_elements/paper_item.dart';

const int duration=20;
const durationCountdown = const Duration(seconds:1);
@PolymerRegister('forex-session-main-chart')
class ForexMainChart extends PolymerElement
{
  ForexMainChart.created() : super.created();
  GoogleChart mainChart;
  GoogleChart balanceChart;
  PaperFab selectPair;
  PaperDialog dialogChart;
  PaperButton btnCharts;
  PaperInput startDate;
  PaperInput endDate;
  TradingSession sess;
  @property
  List<String> currencyPairs;
  @property
  String loadingStatus;
  String countdown;
  int countdownAmt;
  bool playState;
  Timer countdownSesssions;

  ready()
  {

    selectPair = $['selectPair'];
    dialogChart = $['dialogChart'];
    btnCharts =$['btnCharts'];
    startDate =$['startDate'];
    endDate =$['endDate'];
    countdownAmt=duration;
    selectPair.on['tap'].listen(loadChartDialog);
    btnCharts.on['tap'].listen(loadChart);
    loadCurrencyPairs();
    //play();
    //loadBalanceChart();
    //countdownSesssions = new Timer.periodic(durationCountdown,updateCountdown);
  }


  loadCurrencyChart(String pair,String startdt,String enddt,List data)
  {

    mainChart = $['mainChart'];
    String chartTitle="Daily Rates for "+pair;
    var options = {
      'title':chartTitle,
      'legend': 'none',
      'vAxis':{'title':'Price'},
      'hAxis':{'title':'Date'},
      'candlestick': {
        'fallingColor': { 'strokeWidth': 0, 'fill': '#a52714' }, // red
        'risingColor': { 'strokeWidth': 0, 'fill': '#0f9d58' }   // green
      }
    };
    mainChart.options=options;
    mainChart.type="candlestick";
    mainChart.cols=[ {"type":"date"},{"type":"number"},{"type":"number"},{"type":"number"},{"type":"number"}];
    mainChart.rows= data;
    mainChart.on['google-chart-select'].listen(sendMessage);
  }




  sendMessage(Event e)
  {
    window.alert(mainChart.selection[0]["row"].toString());
  }

  playpause()
  {
    if(playState)
      play();
    else
      pause();
  }

  pause()
  {
    if(countdownSesssions!=null && countdownSesssions.isActive)
    {
      countdownSesssions.cancel();
      playState=false;
    }
  }

  play()
  {
    //countdownSesssions = new Timer.periodic(durationCountdown,updateCountdown);
    playState = true;
  }

  loadChartDialog(Event e)
  {
    pause();
    dialogChart.open();
  }

  loadChart(Event e) async
  {
    String pair =currencyPairs[$['menuPair'].selected];
    loadChartData(pair,startDate.value,endDate.value);
    play();
  }

  loadChartData(String pair,String startdt,String enddt) async
  {

    mainChart = $['mainChart'];


    String chartTitle="Daily Rates for "+pair;
    var options = {
      'title':chartTitle,
      'legend': 'none',
      'vAxis':{'title':'Price'},
      'hAxis':{'title':'Date'},
      'candlestick': {
        'fallingColor': { 'strokeWidth': 0, 'fill': '#a52714' }, // red
        'risingColor': { 'strokeWidth': 0, 'fill': '#0f9d58' }   // green
      }
    };
    mainChart.options=options;
    mainChart.type="candlestick";
    mainChart.cols=[ {"type":"date"},{"type":"number"},{"type":"number"},{"type":"number"},{"type":"number"}];


    mainChart.rows= await dailyValues(startdt,enddt,pair);
    mainChart.on['google-chart-select'].listen(sendMessage);



  }

  /*updateCountdown(Timer e) async
  {
    countdownAmt=countdownAmt-1;
    if(countdownAmt==0)
    {
      countdownAmt = 20;
      loadBalanceChart("",e);
    }

    set('countdown',countdownAmt.toString());
  }*/

  loadBalanceChart(String session,List data)
  {

    balanceChart =$['balanceChart'];
    String chartTitle="Balance History for $session";
    var options = {
      'title':chartTitle,
      'legend': 'none',
      'vAxis':{'title':'Value'},
      'hAxis':{'title':'Date'}
      };

    balanceChart.options=options;
    balanceChart.type="line";
    balanceChart.cols=[ {"type":"date"},{"type":"number"}];
    balanceChart.rows = data;

  }


  Future<List> dailyValues(String startDt,String endDt,String pair ) async
  {
      var url = "/api/forexclasses/v1/dailyvaluesrange/$pair/$startDt/$endDt";
      String response = await HttpRequest.getString(url);
      return readResponse(response);
  }

  Future<List> balances() async
  {
    var url = "/api/forexclasses/v1/getsession/testSession";
    String response = await HttpRequest.getString(url);
    return readResponseSession(response);
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

  List readResponseSession(String responseText)
  {


    sess = new TradingSession.fromJSON(responseText);
    Map session =JSON.decode(responseText);
    var data=new List();
    for(Map dailyVal in sess.sessionUser.primaryAccount.balanceHistory)
    {
      var dval = new List();
      dval.add(DateTime.parse(dailyVal["date"]));
      dval.add(dailyVal["amount"]);
      data.add(dval);
    }
    return data;
  }

  loadCurrencyPairs() async
  {
    var url = "/api/forexclasses/v1/pairs";
    String request = await HttpRequest.getString(url);
    set('currencyPairs', JSON.decode(request));

  }
  List testValues()
  {

     List table = [[DateTime.parse('2011-01-01'), 20, 28, 38, 45],
  [DateTime.parse('2011-01-02'), 31, 38, 55, 66],
  [DateTime.parse('2011-01-03'), 50, 55, 77, 80],
  [DateTime.parse('2011-01-04'), 77, 77, 66, 50],
  [DateTime.parse('2011-01-05'), 68, 66, 22, 15]];

    return table;
  }


}
