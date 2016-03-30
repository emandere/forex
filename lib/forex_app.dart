import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:async';
import 'dart:js';
import 'candle_stick.dart';
import 'dart:convert';
import 'package:paper_elements/paper_input.dart';
import 'package:core_elements/core_menu.dart';
import 'forex_classes.dart';
import 'forex_chart.dart';
import 'package:http/browser_client.dart';



/// A Polymer `<main-app>` element.
@CustomTag('forex-app')
class ForexApp extends PolymerElement
{
  @observable var item;
  @observable var itemIndex;
  @observable List<String> currencyPairs;
  @observable List<String> userNames;
  @observable String userId;
  @observable double mainBalance;
  @published String playPause;

  var showChart;
  User currentUser;
  Timer myTimer;
  Chart testChart;
  //DivElement visualization;
  /// Constructor used to create instance of MainApp.
  ForexApp.created() : super.created();
  ready()
  {

    super.ready();
    var panel = shadowRoot.querySelector('#drawerPanel');
    showChart = shadowRoot.querySelector('#dialogChart');
    var navMenu = shadowRoot.querySelector("#naviconmenu");
    var navMain = shadowRoot.querySelector("#navicon");
    var selectPair = shadowRoot.querySelector("#selectPair");
    var btnCharts = shadowRoot.querySelector("#btnCharts");
    var btnCancel = shadowRoot.querySelector("#btnCancel");
    var btnAddUser = shadowRoot.querySelector("#btnAddUser");
    var btnPlayPause = shadowRoot.querySelector("#btnPlayPause");

    CoreMenu mnMain = shadowRoot.querySelector("#mainMenu");

    testChart = shadowRoot.querySelector("#testChart");

    //dr fc testChart.helloworld();
    panel.forceNarrow=true;
    navMenu.onClick.listen((event) =>panel.togglePanel());
    navMain.onClick.listen((event) =>panel.togglePanel());
    selectPair.onClick.listen((event) =>showChart.toggle());
    btnCharts.onClick.listen(loadChart);
    btnCancel.onClick.listen((event) =>showChart.toggle());
    btnAddUser.onClick.listen(saveUser);
    btnPlayPause.onClick.listen(playPauseEvent);



    var mnMainSub = mnMain.onClick.listen((event) =>panel.togglePanel());//mnMain.onClick.listen(updatePage);
    itemIndex =0;
    loadCurrencyPairs();
    //userNames=['AAA','BBB',"CCC"];
    loadUserNames();

    playPause ='pause';
    myTimer=null;

    testChart.dtStartDate =DateTime.parse("2007-01-01");
    testChart.dtEndDate =DateTime.parse("2007-06-01");

    super.ready();
  }

  playPauseEvent( var e)
  {

    const oneSec = const Duration(seconds:1);
    if(myTimer!=null && myTimer.isActive)
    {
      myTimer.cancel();
      playPause ='play-arrow';
      //lstTimers.clear();
    }
    else
    {
      //window.alert("Here!");
      //myTimer = null;
      myTimer = new Timer.periodic(oneSec, testChart.updateChart);
      playPause ='pause';
      //lstTimers.add(new Timer.periodic(oneSec, updateChart));
      //myTime
    }
  }

  /*updatePage(var event)
  {

    PaperInput txtUser = shadowRoot.querySelector("#txtUser");
    txtUser.value ="";

    CoreMenu mnMain = shadowRoot.querySelector("#mainMenu");



  }*/

  saveUser(var event)
  {
    User user = new User();
    PaperInput txtUser = shadowRoot.querySelector("#txtUser");
    user.id=txtUser.value;
    user.status="heredd";
    txtUser.value = "";

    user.primaryAccount.fundAccount(1001.00);

    Trade euro= new Trade();
    euro.pair ="EURUSD";

    user.primaryAccount.Trades.add(euro);

    //UserData userdata = new UserData();
    //userdata.data = JSON.encode(user.toJson());

    //final BrowserClient _client = new BrowserClient();

    //Forexclasses myclass = new Forexclasses(_client);
    //myclass.addUserPost(userdata);
    //HttpRequest.postFormData('http://127.0.0.1:8080/api/forexclasses/v1/adduserpost', userdata.toJson());

    ///HttpRequest request = new HttpRequest(); // create a new XHR

    var url = "http://127.0.0.1:8080/api/forexclasses/v1/adduserpost";
    //request.open("POST", url, async: false);

    UserData myData = new UserData();
    myData.data=user.toJson();
    HttpRequest.request(url,method:'POST',sendData:myData.toJson()).then((response)=>loadUserNames());

    //request.send(user.toJson());
  }



  loadCurrencyPairs()
  {
    //var url = "http://localhost:8080/api/forex/v1/pairs";
    var url = "http://localhost:8080/api/forexclasses/v1/mongopairs";
    //var db = new Db('mongodb://127.0.0.1/testdb');
    //var mongoCurrencyPairs = db.collection('currencyPairs');
    //db.open().then(updateCurrencyMongo);
    var request = HttpRequest.getString(url).then(updateCurrencyList);
  }

  loadUserNames()
  {
    var url = "http://localhost:8080/api/forexclasses/v1/usernames";
    updateUserList(String responseText)
    {
      userNames = JSON.decode(responseText);

    }
    var request = HttpRequest.getString(url).then(updateUserList);

  }

  updateUser( Event e, var detail, Node target)
  {

    userId=detail["user"];
    itemIndex = 2;

    var url = "http://127.0.0.1:8080/api/forexclasses/v1/getuser/"+userId;
    //request.open("POST", url, async: false);
    setCurrentUser(result)
    {
       Map jsonResult = JSON.decode(result);
       currentUser = new User.fromJsonMap(jsonResult[0]);
       mainBalance = currentUser.primaryAccount.NetAssetValue();
    }

    var request = HttpRequest.getString(url).then(setCurrentUser);

  }

  returnToUsers( Event e, var detail, Node target)
  {
    //window.alert("hello");
    itemIndex=0;
  }



  void fireAway()
  {
    window.alert("hello");
  }

  updateCurrencyList(String responseText)
  {
    currencyPairs = JSON.decode(responseText);
  }

  loadChart(var Event)
  {
    var chartSpinner = shadowRoot.querySelector("#chartSpinner");
    ForexChart.load().then(loadData).then((var x){showChart.close();chartSpinner.active=true;});
  }

  loadData(Window Test)
  {
    //var selectPair = shadowRoot.querySelector("#selectPair");

    //var url = "http://localhost:8080/api/forex/v1/dailyvalues/"+currencyPairs[$['menuPair'].selected];
    //var url = "http://localhost:8080/api/forexclasses/v1/dailyvalues/"+currencyPairs[$['menuPair'].selected];

    String startDate=$['startDate'].value;
    String endDate = $['endDate'].value;
    var url = "http://localhost:8080/api/forexclasses/v1/dailyvaluesrange/"+currencyPairs[$['menuPair'].selected]+"/"+startDate+"/"+endDate;

    var request = HttpRequest.getString(url).then(drawChart);
  }

  drawChart(String responseText)
  {
    var chartSpinner = shadowRoot.querySelector("#chartSpinner");
    var data=readResponse(responseText);
    final DivElement visualization = shadowRoot.querySelector('#historychart');
    final DivElement visualizationHistogram = shadowRoot.querySelector('#historygramchart');
    var options = {
      'title':'Currency Pair '+ currencyPairs[$['menuPair'].selected],
      'legend': 'none',
      'vAxis':{'title':'Price'},
      'hAxis':{'title':'Date'},
      'candlestick': {
        'fallingColor': { 'strokeWidth': 0, 'fill': '#a52714' }, // red
        'risingColor': { 'strokeWidth': 0, 'fill': '#0f9d58' }   // green
      }
    };

    var optionsHistogram = {
      'title':'Histogram '+ currencyPairs[$['menuPair'].selected],
      'legend': 'none'
    };
    ForexChart gauge = new ForexChart(visualization,data, "Slider", options);
    ForexHistogram gauge2 = new ForexHistogram(visualizationHistogram,data, "Slider", optionsHistogram);
    chartSpinner.active=false;
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
    //data.add(['date','Col 1','Col 2','Col 3','Col 4']);
    PaperInput startDate = shadowRoot.querySelector("#startDate");
    PaperInput endDate = shadowRoot.querySelector("#endDate");
    for(ForexDailyValue dailyVal in
        dailyVals/*.where((ForexDailyValue i) => DateTime.parse(i.date).isAfter(DateTime.parse(startDate.value))
                                            && DateTime.parse(i.date).isBefore(DateTime.parse(endDate.value)))*/)
    {
      var dval = new List();
      //dval.add(dailyVal.date);
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

class ForexChart {
  var jsOptions;
  var jsTable;
  var jsChart;

  ForexChart(Element element,var data, String title,Map options) {

    final vis = context["google"]["visualization"];
    jsTable = new JsObject(vis["DataTable"]);
    jsTable.callMethod('addColumn',['date','Col 0']);
    jsTable.callMethod('addColumn',['number','Col 1']);
    jsTable.callMethod('addColumn',['number','Col 2']);
    jsTable.callMethod('addColumn',['number','Col 3']);
    jsTable.callMethod('addColumn',['number','Col 4']);
    //jsTable = vis.callMethod('arrayToDataTable',[new JsObject.jsify(data)]);
    jsTable.callMethod('addRows',[new JsObject.jsify(data)]);
    jsChart = new JsObject(vis["CandlestickChart"], [element]);//new JsObject(vis["Gauge"], [element]);

    jsOptions = new JsObject.jsify(options);
    draw();
  }

  void draw() {
    //jsTable.callMethod('setValue', [0, 1, value]);
    jsChart.callMethod('draw', [jsTable, jsOptions]);
  }


  static Future load() {
    Completer c = new Completer();
    context["google"].callMethod('load',
        ['visualization', '1', new JsObject.jsify({
          'packages': ['corechart'],//['gauge'],
          'callback': new JsFunction.withThis(c.complete)
        })]);
    return c.future;
  }


}

class ForexHistogram {
  var jsOptions;
  var jsTable;
  var jsChart;

  ForexHistogram(Element element,var data, String title,Map options) {

    final vis = context["google"]["visualization"];
    //jsTable = new JsObject(vis["DataTable"]);
    //jsTable.callMethod('addColumn',['date','day']);
    //jsTable.callMethod('addColumn',['number','Daily Moves']);
    List histodata=new List();
    histodata.add(['Date','Moves']);
    for(List candle in data)
    {
      List tempList = new List();
      num move = ((candle[3]-candle[2])/candle[2])*100;
      tempList.add(candle[0].toString());
      tempList.add(move);
      histodata.add(tempList);
    }

    /*jsTable.callMethod('addColumn',['number','Col 1']);
    jsTable.callMethod('addColumn',['number','Col 2']);
    jsTable.callMethod('addColumn',['number','Col 3']);
    jsTable.callMethod('addColumn',['number','Col 4']);*/
    //jsTable = vis.callMethod('arrayToDataTable',[new JsObject.jsify(data)]);
    //jsTable.callMethod('addRows',[new JsObject.jsify(histodata)]);
    jsTable = vis.callMethod('arrayToDataTable',[new JsObject.jsify(histodata)]);
    jsChart = new JsObject(vis["Histogram"], [element]);//new JsObject(vis["Gauge"], [element]);

    jsOptions = new JsObject.jsify(options);
    draw();
  }

  void draw() {
    //jsTable.callMethod('setValue', [0, 1, value]);
    jsChart.callMethod('draw', [jsTable, jsOptions]);
  }


  static Future load() {
    Completer c = new Completer();
    context["google"].callMethod('load',
        ['visualization', '1', new JsObject.jsify({
          'packages': ['corechart'],//['gauge'],
          'callback': new JsFunction.withThis(c.complete)
        })]);
    return c.future;
  }


}
