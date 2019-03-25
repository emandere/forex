

import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
main() async
{

 newcall();

}

old() async
{
  var file = new File("keys");
  var authorization = {"Authorization": await file.readAsString()};
  var text = await http.read("https://api-fxtrade.oanda.com/labs/v1/historical_position_ratios?instrument=EUR_USD&period=86400",
      headers:authorization);
  print(text);


  var fileAccount = new File("account");
  var accountId = await fileAccount.readAsString();
  var url =  "https://api-fxtrade.oanda.com/v3/accounts/$accountId/orders";
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

newcall() async
{
  var file = new File("keys");
  var authorization = {"Authorization": await file.readAsString()};
  var content = {'Content-type' : 'application/json'};

  var combinedheaders =
  {
    "Authorization": await file.readAsString(),
    'Content-type' : 'application/json'
  };
  //var text = await http.read("https://api-fxtrade.oanda.com/labs/v1/historical_position_ratios?instrument=EUR_USD&period=86400",
  //    headers:authorization);
  //print(text);


  var fileAccount = new File("account");
  var accountId = await fileAccount.readAsString();
  var url =  "https://api-fxtrade.oanda.com/v3/accounts/$accountId/orders";
  //Take note of the -2 for short
  var order =
            {
                "order":
                {
                    "units":"-2",
                    "instrument": "EUR_USD",
                    "timeInForce": "FOK",
                    "type": "MARKET",
                    "positionFill": "DEFAULT",
                    "stopLossOnFill":
                    {
                      "price": "1.14530"
                    },
                    "takeProfitOnFill":
                    {
                      "price": "1.11530"
                    }
                }
            };
  //var order = {};
  //order["units"]="-2";
  //order["instruments"]="EUR_USD";
  print(url);
  var response = await http.post(url,body:JSON.encode(order),headers:combinedheaders);
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");

}
