@HtmlImport('forex_pair_header.html')
library forex.lib.forex_pair_header;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';
@PolymerRegister('forex-pair-header')
class ForexPairHeader extends PolymerElement
{

  ForexPairHeader.created() : super.created();
  factory ForexPairHeader() => new Element.tag('forex-pair-header') as ForexPairHeader;
  ready()
  {

  }
}