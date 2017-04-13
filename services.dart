library io_rpc_sample;

import 'dart:io';
import 'dart:async';

//import 'packages/rpc/rpc.dart';
import 'package:rpc/rpc.dart';
import 'package:http_server/http_server.dart';
import 'lib/forex_data.dart';
import 'lib/forex_api.dart';
import 'lib/forex_mongo.dart';
import 'lib/candle_stick.dart';


const String _API_PREFIX = '/api';
final ApiServer _apiServer = new ApiServer(apiPrefix: _API_PREFIX, prettyPrint: true);
final String _buildPath = Platform.script.resolve('build/web/').toFilePath();
final VirtualDirectory _clientDir = new VirtualDirectory(_buildPath);

Future requestHandler(HttpRequest request) async {


  if (request.uri.path.startsWith(_API_PREFIX)) {
    // Handle the API request.
    var apiResponse;
    try {
      var apiRequest = new HttpApiRequest.fromHttpRequest(request);
      apiResponse =
      await _apiServer.handleHttpApiRequest(apiRequest);
    } catch (error, stack) {
      var exception =
      error is Error ? new Exception(error.toString()) : error;
      apiResponse = new HttpApiResponse.error(
          HttpStatus.INTERNAL_SERVER_ERROR, exception.toString(),
          exception, stack);
    }
    return sendApiResponse(apiResponse, request.response);
  } else if (request.uri.path == '/') {
    // Redirect to the piratebadge.html file. This will initiate
    // loading the client application.
    request.response.redirect(Uri.parse('index.html'));
  } else {
    // Serve the requested file (path) from the virtual directory,
    // minus the preceeding '/'. This will fail with a 404 Not Found
    // if the request is not for a valid file.
    var fileUri = new Uri.file(_buildPath)
    .resolve(request.uri.path.substring(1));
    _clientDir.serveFile(new File(fileUri.toFilePath()), request);
  }
}

setupDatabase(ForexMongo mongoLayer) async
{

  var result;
  List<String> pairs = ["AUDUSD","EURUSD","GBPUSD","NZDUSD","USDCAD","USDCHF","USDJPY"];
  List<String> mongoPairs = await mongoLayer.readMongoPairs();
  if(mongoPairs.isEmpty)
  {
    await mongoLayer.ClearForexValues();
    await mongoLayer.AddCurrencies(pairs);
    for (String pair in pairs) {
      List<String> strvalues = new File(
          'data/' + pair + '/' + pair + 'dailyval.txt').readAsLinesSync();
      List<ForexDailyValue> dailyvals = new List<ForexDailyValue>();
      for (String line in strvalues) {
        ForexDailyValue val = new ForexDailyValue.fromString(
            line, pairName: pair);
        result = await mongoLayer.addForexDailyValue(val);
        print(result);
      }
    }
  }
}

main(List<String> arguments) async
{
  print ("Mode:"+arguments[0]);
  print(_buildPath+" here");


  ForexMongo mongoLayer = new ForexMongo(arguments[0]);
  await mongoLayer.db.open();
  await setupDatabase(mongoLayer);
  print("DB set up complete");
  _apiServer.addApi(new ForexData());
  _apiServer.addApi(new ForexClasses(mongoLayer));
  _apiServer.enableDiscoveryApi();
  HttpServer server = await HttpServer.bind(InternetAddress.ANY_IP_V6,80);

  server.listen(requestHandler);
}