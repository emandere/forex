

import 'package:http/http.dart' as http;
import 'dart:io';
main() async
{
  var file = new File("keys");
  var authorization = {"Authorization": await file.readAsString()};
  var text = await http.read("https://api-fxtrade.oanda.com/labs/v1/historical_position_ratios?instrument=EUR_USD&period=86400",
  headers:authorization);
  print(text);


  var fileAccount = new File("account");
  var accountId = await fileAccount.readAsString();
  var url =  "https://api-fxtrade.oanda.com/v1/accounts/$accountId/orders";
  var bodyMap = {};

  bodyMap["instrument"]="AUD_USD";
  bodyMap["units"]="2";
  bodyMap["side"]="sell";
  bodyMap["type"]="market";
  bodyMap["stopLoss"]="0.768";
  bodyMap["takeProfit"]="0.761";
  var response = await http.post(url,body:bodyMap,headers:authorization);
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");


}