import 'package:http/http.dart' as http;
import 'lib/forex_classes.dart';
main() async
{
  TradingSession testSession;
  testSession=new TradingSession();
  testSession.id="testSession78";
  testSession.sessionUser.id="testSessionUser78";
  PostData myData = new PostData();
  myData.data=testSession.toJson();

  var text = await http.read("http://23.22.66.239/api/forexclasses/v1/pairs");
  print(text);

  var url = "http://23.22.66.239/api/forexclasses/v1/addsessionpost";
  
  var response = await http.post(url,body:myData.toJsonMap());
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");

}