@HtmlImport('forex_session_detail.html')
library forex.lib.forex_session_detail;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/paper_checkbox.dart';
import 'package:polymer_elements/paper_icon_button.dart';
import 'package:polymer_elements/paper_listbox.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_elements/paper_dialog.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_spinner.dart';
import 'package:polymer_elements/paper_input.dart';

@PolymerRegister('forex-session-detail')
class ForexSessionDetail extends PolymerElement
{
  String _balance;
  String _pl;
  String _id;
  String _startDate;
  String _currentDate;
  String _closedTrades;
  String _pct;
  bool _selectSession = true;
  List<String> _currencyPairs =[];

  @property bool get selectSession => _selectSession;
  @reflectable set selectSession(bool value)
  {
    _selectSession=value;
    PaperCheckbox selectSession = $['selectSession'];
    PaperIconButton filterSession =$['filterSession'];


    selectSession.hidden=!value;
    filterSession.hidden=value;

    SpinnerOff();
  }

  @property List<String> get currencyPairs => _currencyPairs;
  @reflectable set currencyPairs(List<String> value)
  {
    _currencyPairs=value;
    set('currencyPairs', _currencyPairs);
  }

  @property String get balance => _balance;
  @reflectable set balance(String value)
  {
    _balance=value;
    set('balance', _balance);
  }
  @property String get pl => _pl;
  @reflectable set pl(String value)
  {
    _pl=value;
    set('pl', _pl);
  }
  @property String get id => _id;
  @reflectable set id(String value)
  {
    _id=value;
    set('id', _id);
  }
  @property String get startDate => _startDate;
  @reflectable set startDate(String value)
  {
    _startDate=value;
    set('startDate', _startDate);
  }
  @property String get currentDate => _currentDate;
  @reflectable set currentDate(String value)
  {
    _currentDate=value;
    set('currentDate', _currentDate);
  }
  @property String get closedTrades => _closedTrades;
  @reflectable set closedTrades(String value)
  {
    _closedTrades=value;
    set('closedTrades', _closedTrades);
  }
  @property String get pct => _pct;
  @reflectable set pct(String value)
  {
    _pct=value;
    set('pct', _pct);
  }
  ForexSessionDetail.created() : super.created();
  factory ForexSessionDetail() => new Element.tag('forex-session-detail') as ForexSessionDetail;
  ready()
  {
      PaperCheckbox selectSession = $['selectSession'];
      PaperIconButton filterSession = $['filterSession'];
      PaperButton btnFilterSession =$['btnFilterSession'];

      selectSession.on["tap"].listen(sendSelectSession);
      filterSession.on["tap"].listen(openDialog);
      btnFilterSession.on["tap"].listen(sendFilterSession);
  }

  SpinnerOn()
  {
     PaperSpinner  filterSpinner = $['filterSpinner'];
     filterSpinner.active=true;
  }

  SpinnerOff()
  {
    PaperSpinner  filterSpinner = $['filterSpinner'];
    filterSpinner.active=false;
  }

  clearSelection()
  {
    PaperCheckbox selectSession = $['selectSession'];
    selectSession.checked=false;
  }

  void sendSelectSession(var event)
  {

    this.fire('selectsession',detail: {"id":id});
  }

  void sendFilterSession(var event)
  {
    PaperDropdownMenu currencyPairsMenu = $['currencyPairsMenu'];
    PaperInput startFilterDateInput=$['startFilterDate'];
    PaperInput endFilterDateInput=$['endFilterDate'];

    var startFilterDate = startFilterDateInput.value.isEmpty ? startDate : startFilterDateInput.value;
    var endFilterDate = endFilterDateInput.value.isEmpty ? currentDate : endFilterDateInput.value;
    
    SpinnerOn();
    this.fire('selectfiltersession',detail: { "pair":currencyPairsMenu.value,
                                              "startFilterDate":startFilterDate,
                                              "endFilterDate":endFilterDate});
  }

  void openDialog(var event)
  {
      PaperDialog dialogFilter = $['dialogFilter'];
      dialogFilter.open();
  }
}