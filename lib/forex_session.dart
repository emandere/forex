@HtmlImport('forex_session.html')
library forex.lib.forex_session;
import 'dart:html';
import 'dart:convert';

import 'forex_classes.dart';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:forex/forex_session_main_chart.dart';
import 'package:polymer_elements/google_chart.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_menu.dart';
import 'package:polymer_elements/paper_dialog.dart';
import 'package:polymer_elements/paper_fab.dart';
import 'package:polymer_elements/iron_icons.dart';
import 'package:polymer_elements/iron_pages.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/paper_drawer_panel.dart';
import 'package:polymer_elements/paper_icon_button.dart';
import 'package:polymer_elements/paper_header_panel.dart';
import 'package:polymer_elements/paper_toolbar.dart';
import 'package:polymer_elements/paper_toast.dart';
import 'package:polymer_elements/paper_listbox.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/iron_iconset.dart';
import 'package:polymer_elements/av_icons.dart';
@PolymerRegister('forex-session')
class ForexSession extends PolymerElement
{
  TradingSession tradeSession;
  @property
  int itemIndex;
  @property
  List<String> sessions;
  ForexSession.created() : super.created();
  ready()
  {
     PaperIconButton navIconMenu = $['navIconMenu'];
     PaperIconButton navIconMenuBack = $['navIconMenuBack'];
     PaperDrawerPanel panel = $['drawerPanel'];
     PaperFab createForexSession=$['createForexSession'];
     PaperDialog dialogSession=$['dialogSession'];
     PaperButton btnCreateSession=$['btnCreateSession'];
     PaperItem sessionItem=$['sessionItem'];
     PaperMenu menuPage=$['menuPage'];

     navIconMenu.on['tap'].listen((event)=>panel.togglePanel());
     navIconMenuBack.on['tap'].listen((event)=>panel.togglePanel());
     createForexSession.on['tap'].listen((event)=>dialogSession.open());
     btnCreateSession.on['tap'].listen(CreateUserSession);
     menuPage.on['tap'].listen((event)=>panel.togglePanel());
     panel.forceNarrow=true;
     set('itemIndex',0);
      //navIconMenu.onClick.listen((event)=>panel.togglePanel());
     loadSessions();
  }

  loadSessions() async
  {
    var url = "/api/forexclasses/v1/sessions";
    String request = await HttpRequest.getString(url);
    set('sessions', JSON.decode(request));

  }

  CreateUserSession(Event e)
  {
      PaperInput sessionId=$['sessionId'];
      PaperInput startDate=$['startDate'];
      PaperInput primaryAmount=  $['primaryAmount'] ;
      PaperInput secondaryAmount=  $['secondaryAmount'] ;


      tradeSession = new TradingSession();
      tradeSession.id=sessionId.value;
      tradeSession.sessionUser.id="testSessionUser";
      tradeSession.startDate=DateTime.parse(startDate.value);
      tradeSession.currentTime=DateTime.parse(startDate.value);
      tradeSession.fundAccount("primary",double.parse(primaryAmount.value));
      tradeSession.fundAccount("secondary",double.parse(secondaryAmount.value));

      SaveSession();
  }

  SaveSession()
  {
    var url = "/api/forexclasses/v1/addsessionpost";//"/api/forexclasses/v1/addsessionpost";
    PostData myData = new PostData();


    myData.data=tradeSession.toJson();

    HttpRequest.request(url, method:'POST',
        requestHeaders: {"content-type": "application/json"},
        sendData:myData.toJson());


    PaperToast toastSession=$['toastSession'];
    toastSession.text=tradeSession.id+" created and saved";
    toastSession.duration=3000;
    toastSession.open();
    loadSessions();
  }

}