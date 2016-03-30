library treeapi;
import 'dart:io';
import 'package:rpc/rpc.dart';
import 'dart:async';


class TreeResponse
{
  String result;
  TreeResponse();
}

@ApiClass(version: '0.1')
class TreeApi
{
  TreeApi();
  @ApiMethod(path: 'hello')
  TreeResponse hello() { return new TreeResponse()..result = 'Hello there!'; }
}