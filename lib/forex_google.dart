import 'package:js/js.dart';
import'dart:html';
import 'dart:js';

@JS('google.load')
//external load(String packageName,String version,JsObject options);
external load(name,version,options);

@JS("JSON.stringify")
external String stringify(obj);


@JS()
class Date
{
  external Date(String datetime);
}