@HtmlImport('forex_pair.html')
library forex.lib.forex_pair;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';
import 'package:polymer_elements/iron_iconset.dart';
import 'package:polymer_elements/iron_icon.dart';
import 'package:polymer_elements/paper_icon_button.dart';
@PolymerRegister('forex-pair')
class ForexPair extends PolymerElement
{
  String _pair;
  String _open;
  String _high;
  String _low;
  String _close;
  String _move;
  String _moveicon;

  @property String get pair => _pair;
  @reflectable set pair(String value)
  {
    _pair=value;
    set('pair', _pair);
  }
  @property String get open => _open;
  @reflectable set open(String value)
  {
    _open=value;
    set('open', _open);
  }
  @property String get high => _high;
  @reflectable set high(String value)
  {
    _high=value;
    set('high', _high);
  }


  @property String get low => _low;
  @reflectable set low(String value)
  {
    _low=value;
    set('low', _low);
  }
  @property String get close => _close;
  @reflectable set close(String value)
  {
    _close=value;
    set('close', _close);
  }

  @property String get move => _move;
  @reflectable set move(String value)
  {
      IronIcon direction = $['direction'];
      if(value=="up")
      {
        direction.style.color = "green";
        moveicon="icons:arrow-upward";
      }
      else
      {
        direction.style.color = "red";
        moveicon="icons:arrow-downward";
      }
  }

  @property String get moveicon => _moveicon;
  @reflectable set moveicon(String value) => set('moveicon', value);

  ForexPair.created() : super.created();
  factory ForexPair() => new Element.tag('forex-pair') as ForexPair;
  ready()
  {
      PaperIconButton launchPair=$['launchPair'];
      launchPair.on['tap'].listen(sendLaunchPair);
  }

  void sendLaunchPair(var event)
  {
    this.fire('launchpair',detail: {"pair":pair});
  }
}