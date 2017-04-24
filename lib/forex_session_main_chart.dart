@HtmlImport('forex_session_main_chart.html')
library forex.lib.forex_session_main_chart;

import 'dart:html';
import 'dart:convert';
import 'candle_stick.dart';
import 'dart:async';
import 'forex_classes.dart';
import 'forex_session_detail.dart';
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


@PolymerRegister('forex-session-main-chart')
class ForexMainChart extends PolymerElement
{
  ForexSessionDetail _sessionDetail;
  ForexMainChart.created() : super.created();
  @property ForexSessionDetail get sessionDetail => _sessionDetail;
  @reflectable set sessionDetail(ForexSessionDetail value)
  {
    _sessionDetail = $['sessionDetail'] as ForexSessionDetail;
    _sessionDetail..id = value.id
      ..startDate=value.startDate
      ..currentDate=value.currentDate
      ..balance = value.balance
      ..pl = value.pl
      ..currencyPairs=value.currencyPairs
      ..closedTrades=value.closedTrades
      ..selectSession=false
      ..pct= value.pct;

  }
  loadCurrencyChart(String pair,List data)
  {
    GoogleChart mainChart = $['mainChart'];
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
    //mainChart.on['google-chart-select'].listen(sendMessage);
  }

  loadBalanceChart(String session,List data)
  {
    GoogleChart balanceChart =$['balanceChart'];
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

  loadTradesHistogram(String session,List data)
  {
    GoogleChart histogramChart =$['histogramChart'];
    String chartTitle="Histogram of P/L for Closed Trades for $session";
    var options = {
      'title':chartTitle,
      'legend': 'none',
      'vAxis':{'title':'Number of Trades'},
      'hAxis':{'title':'P/L'}
    };

    histogramChart.options=options;
    histogramChart.type="histogram";
    histogramChart.cols=[ {"type":"string"},{"type":"number"}];
    histogramChart.rows = data;
  }

  loadTradesTimeHistogram(String session,List data)
  {
    GoogleChart histogramTimeChart =$['histogramTimeChart'];
    String chartTitle="Histogram of Trade Timespan for $session";
    var options = {
      'title':chartTitle,
      'legend': 'none',
      'vAxis':{'title':'Number of Trades'},
      'hAxis':{'title':'Trade Length'}
    };

    histogramTimeChart.options=options;
    histogramTimeChart.type="histogram";
    histogramTimeChart.cols=[ {"type":"string"},{"type":"number"}];
    histogramTimeChart.rows = data;
  }

  hideCharts()
  {
    GoogleChart mainChart = $['mainChart'];
    GoogleChart balanceChart =$['balanceChart'];
    GoogleChart histogramChart =$['histogramChart'];
    GoogleChart histogramTimeChart =$['histogramTimeChart'];

    mainChart.hidden=true;
    balanceChart.hidden=true;
    histogramChart.hidden=true;
    histogramTimeChart.hidden=true;
  }

  showCharts()
  {
    GoogleChart mainChart = $['mainChart'];
    GoogleChart balanceChart =$['balanceChart'];
    GoogleChart histogramChart =$['histogramChart'];
    GoogleChart histogramTimeChart =$['histogramTimeChart'];

    mainChart.hidden=false;
    balanceChart.hidden=false;
    histogramChart.hidden=false;
    histogramTimeChart.hidden=false;
  }

}
