import 'package:polymer/polymer.dart';
@CustomTag('user-card')
class UserCard extends PolymerElement
{
  @published String cardTitle;
  @published String primaryBalance;
  @published bool isMain;
  UserCard.created() : super.created();
  ready()
  {
    var btnUsers = shadowRoot.querySelector("#btnUsers");
    btnUsers.onClick.listen(backUsers);

    if(cardTitle!="Primary" && cardTitle!="Secondary")
      btnUsers.hidden=false;
    else
      btnUsers.hidden=true;
    super.ready();
  }

  void backUsers(var event)
  {
    this.fire('backtousers');
  }
}