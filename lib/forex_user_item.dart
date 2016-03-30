import 'package:polymer/polymer.dart';
import 'dart:html';
import 'forex_classes.dart';
import 'dart:convert';
@CustomTag('user-item')
class UserItem extends PolymerElement
{
  @published String userId;
  @published List<String> myusernames;
  @observable var itemIndex;
  UserItem.created() : super.created();
  ready()
  {
    var btnDeleteUser = shadowRoot.querySelector("#btnDeleteUser");
    var btnUpdateUser = shadowRoot.querySelector("#btnUpdateUser");
    var btnEditUser = shadowRoot.querySelector("#btnEditUser");
    var btnShowUser = shadowRoot.querySelector("#btnShowUser");

    btnDeleteUser.onClick.listen(deleteUser);
    btnUpdateUser.onClick.listen(sendUpdateEvent);
    btnEditUser.onClick.listen(changeSection);
    btnShowUser.onClick.listen(changeSection);
    itemIndex = 0;
    super.ready();
  }

  changeSection(var event)
  {
    //window.alert("hello");
    if(itemIndex == 0)
      itemIndex = 1;
    else
      itemIndex =0;
  }
  deleteUser(var event)
  {
    var url = "http://127.0.0.1:8080/api/forexclasses/v1/removeuser";
    //request.open("POST", url, async: false);

    UserData myData = new UserData();
    myData.data=userId;
    HttpRequest.request(url,method:'POST',sendData:myData.toJson()).then((response)=>sendDeletedEvent());
    //sendEvent();
  }

  void sendDeletedEvent()
  {
    this.fire('deleteduser');
  }

  void sendUpdateEvent(var event)
  {
    this.fire('updateuser',detail: {"user":userId});
  }
}