@HtmlImport('forex_pair.html')
library forex.lib.forex_pair;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_elements/paper_card.dart';
@PolymerRegister('forex-pair')
class ForexPair extends PolymerElement
{
  String _pair;
  String _open;
  String _high;
  String _low;
  String _close;
  @property String get pair => _pair;
  @reflectable set pair(String value) => set('pair', value);
  @property String get open => _open;
  @reflectable set open(String value) => set('open', value);
  @property String get high => _high;
  @reflectable set high(String value) => set('high', value);
  @property String get low => _low;
  @reflectable set low(String value) => set('low', value);
  @property String get close => _close;
  @reflectable set close(String value) => set('close', value);
  ForexPair.created() : super.created();
  factory ForexPair() => new Element.tag('forex-pair') as ForexPair;
  ready()
  {

  }
}