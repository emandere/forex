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
  @property String get pair => _pair;
  @reflectable set pair(String value) => set('pair', value);
  ForexPair.created() : super.created();
  factory ForexPair() => new Element.tag('forex-pair') as ForexPair;
  ready()
  {

  }
}