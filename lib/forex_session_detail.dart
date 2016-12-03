@HtmlImport('forex_session_detail.html')
library forex.lib.forex_session_detail;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/paper_checkbox.dart';
import 'package:web_components/web_components.dart';
@PolymerRegister('forex-session-detail')
class ForexSessionDetail extends PolymerElement
{
  String _balance;
  String _pl;
  String _id;
  String _startDate;
  String _currentDate;
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
  ForexSessionDetail.created() : super.created();
  factory ForexSessionDetail() => new Element.tag('forex-session-detail') as ForexSessionDetail;
  ready()
  {
      PaperCheckbox selectSession = $['selectSession'];
      selectSession.on["tap"].listen(sendSelectSession);
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
}