import 'dart:io';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:gcloud/db.dart' as db;
import 'package:gcloud/storage.dart';
import 'package:gcloud/pubsub.dart';
import 'package:gcloud/service_scope.dart' as ss;
import 'package:gcloud/src/datastore_impl.dart' as datastore_impl;
import 'dart:convert';

class Account extends db.Model
{
  Account()
  {

  }
  Account.fromJsonMap(String acc)
  {
    accountname=JSON.decode(acc)['name'];
  }

  Map toJSON()
  {
    return {"name":accountname};
  }

  String toJSONString()
  {
     return JSON.encode(toJSON());
  }

  String accountname;
}

@db.Kind()
class Session extends db.Model {
  @db.StringProperty()
  String sessionname;

  @db.DateTimeProperty()
  DateTime startDate;

  @db.DateTimeProperty()
  DateTime endDate;

  @db.StringProperty()
  String primaryAccJSON;

  Account primaryAcc;

 }
main() async
{
    print("Hello");
    var jsonCredentials = new File('forexapp.json').readAsStringSync();
    var credentials = new auth.ServiceAccountCredentials.fromJson(jsonCredentials);

    var scopes = []
      ..addAll(datastore_impl.DatastoreImpl.SCOPES)
      ..addAll(Storage.SCOPES)
      ..addAll(PubSub.SCOPES);
    var client = await auth.clientViaServiceAccount(credentials, scopes);
    var dBase = new db.DatastoreDB(
        new datastore_impl.DatastoreImpl(client, 'edforexapp-150502'));

    for(var i=0;i<200;i++)
    {

      var acc = new Account()
        ..accountname = 'delete'+i.toString();

      var session = new Session()
        ..sessionname = 'cleanSession'
        ..startDate = new DateTime(2011, 01, 01).toUtc()
        ..endDate = new DateTime(2011, 01, 02).toUtc()
        ..primaryAccJSON = acc.toJSONString();

      print("Writing "+acc.accountname);
      await dBase.commit(inserts: [session]);
    }
    print("Querying Sessions");
    var sessions = (await dBase.query(Session).run()).toList().then(printSession);


   /* List<Session> sessions = (await dBase.query(Session).run()).toList();
    print (sessions[0].name);
    for(Session sess in sessions)
    {
       print(sess.name);
    }*/
}

printSession(List<Session> sessions)
{
  for(Session sess in sessions)
  {
    print(sess.primaryAccJSON);

  }
}