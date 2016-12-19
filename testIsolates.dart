import 'dart:isolate';
import 'dart:async';
import 'dart:core';
main() async
{
  int count = 1;
  List<ReceivePort> ports = new List<ReceivePort>();
  List<Future<Isolate>> echoIsolate = new List<Future<Isolate>>();
  for(int i=0;i<count;i++)
  {
    ports.add(new ReceivePort());
    echoIsolate.add( Isolate.spawnUri(Uri.parse("testEcho.dart"), [i.toString()], ports[i].sendPort));
  }

  for(int i=0;i<count;i++)
  {
    var msg = await ports[i].first;
    print(msg);
  }
}