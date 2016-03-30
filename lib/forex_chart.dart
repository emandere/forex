import 'package:polymer/polymer.dart';
import 'dart:html';
import 'forex_classes.dart';
import 'dart:convert';
import 'forex_google_chart.dart';
import 'dart:async';
import 'dart:js';
import 'forex_google.dart';
import 'candle_stick.dart';

@CustomTag('forex-chart')
class Chart extends PolymerElement
{
  @published String chartTitle;
  @published Map chartOptions;
  @published List chartData;
  @published String startDate;
  @published String endDate;
  @published String myData;
  @published String playPause;
  @published bool startTimer;
  Timer myTimer;
  @published DateTime dtStartDate;
  @published DateTime dtEndDate;
  //List<Timer> lstTimers;
  Chart.created() : super.created();
  ready()
  {
    super.ready();
  }



  helloworld()
  {

    window.alert("hello");
  }


  String twoDigits(int i)
  {
    if(i<10)
       return "0"+i.toString();
    else
      return i.toString();
  }
  updateChart(var event) async
  {
    //testHere(event);
    dtStartDate=dtStartDate.add(new Duration(days: 1));
    dtEndDate=dtEndDate.add(new Duration(days: 1));
    //myData =dtEndDate.year.toString()+"-"+twoDigits(dtEndDate.month)+"-"+ twoDigits(dtEndDate.day);
    chartOptions = {
      'title':chartTitle,
      'legend': 'none',
      'vAxis':{'title':'Price'},
      'hAxis':{'title':'Date'},
      'candlestick': {
        'fallingColor': { 'strokeWidth': 0, 'fill': '#a52714' }, // red
        'risingColor': { 'strokeWidth': 0, 'fill': '#0f9d58' }   // green
      }
    };
    //loadAPI('corechart').then(loadData);
    await loadAPI('corechart');
    var request = await loadData(null);
    chartData = readResponse(request);
    drawChart();
  }

  loadData(var Test)
  {
    String startDate=dtStartDate.year.toString()+"-"+twoDigits(dtStartDate.month)+"-"+ twoDigits(dtStartDate.day);
    String endDate = dtEndDate.year.toString()+"-"+twoDigits(dtEndDate.month)+"-"+ twoDigits(dtEndDate.day);//'2012-01-01';//$['endDate'].value;
    var url = "http://localhost:8080/api/forexclasses/v1/dailyvaluesrange/GBPUSD/"+startDate+"/"+endDate;

    myData=url;
    //var request = HttpRequest.getString(url).then(drawChart);
    return HttpRequest.getString(url);
  }

  static Future loadAPI(String package)
  {
    Completer c = new Completer();
    stringify("hey!");
    load('visualization','1.0',new JsObject.jsify({'packages':[package],'callback':new JsFunction.withThis(c.complete)}));

    /*  context["google"].callMethod('load',
          ['visualization', '1', new JsObject.jsify({
            'packages': [package],//['gauge'],
            'callback': new JsFunction.withThis(c.complete)
          })]);*/

    return c.future;
  }

  drawChart()//(String responseText)
  {
    //window.alert("Here!");
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

    final DivElement graph = shadowRoot.querySelector('#historychart');
    //chartData = readResponse(responseText);

    DataTable jsTable = new DataTable();
    jsTable.addColumn('date','Col 0');
    jsTable.addColumn('number','Col 1');
    jsTable.addColumn('number','Col 2');
    jsTable.addColumn('number','Col 3');
    jsTable.addColumn('number','Col 4');

    jsTable.addRows(new JsObject.jsify(chartData));
    CandlestickChart jsChart = new CandlestickChart(graph);//GoogleDataChart.GetCharts("CandleStickChart",graph);//new CandlestickChart(graph);
    JsObject jsOptions = new JsObject.jsify(chartOptions);
    jsChart.draw(jsTable,jsOptions);

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

      dval.add(new JsObject(context["Date"],[dailyVal.date]));
      dval.add(dailyVal.low);
      dval.add(dailyVal.open);
      dval.add(dailyVal.close);
      dval.add(dailyVal.high);

      data.add(dval);
    }
    return data;
  }
}





