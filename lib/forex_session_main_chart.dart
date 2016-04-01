@HtmlImport('forex_session_main_chart.html')
library forex.lib.forex_session_main_chart;

import 'dart:html';
import 'dart:convert';
import 'candle_stick.dart';
import 'dart:async';

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_elements/google_chart.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_menu.dart';
import 'package:polymer_elements/paper_dialog.dart';
import 'package:polymer_elements/paper_fab.dart';
import 'package:polymer_elements/iron_icons.dart';

@PolymerRegister('forex-session-main-chart')
class ForexMainChart extends PolymerElement
{
  ForexMainChart.created() : super.created();
  GoogleChart mainChart;
  PaperFab selectPair;
  PaperDialog dialogChart;
  PaperButton btnCharts;
  PaperInput startDate;
  PaperInput endDate;

  @property
  List<String> currencyPairs;

  ready()
  {



    selectPair = $['selectPair'];
    dialogChart = $['dialogChart'];
    btnCharts =$['btnCharts'];
    startDate =$['startDate'];
    endDate =$['endDate'];
    //mainChart.on['google-chart-select'].listen(sendMessage);
    selectPair.on['tap'].listen(loadChartDialog);
    btnCharts.on['tap'].listen(loadChart);
    loadCurrencyPairs();


  }
  sendMessage(Event e)
  {
    window.alert(e.type);
  }

  loadChartDialog(Event e)
  {
    dialogChart.open();
  }

  loadChart(Event e) async
  {
    String pair =currencyPairs[$['menuPair'].selected];
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


    mainChart.rows= await dailyValues(startDate.value,endDate.value,pair);

  }

  Future<List> dailyValues(String startDt,String endDt,String pair ) async
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
