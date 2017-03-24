import 'dart:isolate';
import 'dart:async';
import 'dart:core';
import 'dart:io';
main(List<String> arguments) async
{
  int count = 1;
  if(arguments.isNotEmpty)
    count = int.parse(arguments[0]);
  List<ReceivePort> ports = new List<ReceivePort>();
  List<Future<Isolate>> echoIsolate = new List<Future<Isolate>>();



  Stopwatch watch = new Stopwatch();
  watch.start();
  for(int i=0;i<count;i++)
  {
    ports.add(new ReceivePort());
    echoIsolate.add( Isolate.spawnUri(Uri.parse("testEcho.dart"), ["RSIOversold30"], ports[i].sendPort));
  }

  for(int i=0;i<count;i++)
  {
    var msg = await ports[i].first;
    print(msg);
  }
  watch.stop();
  print(watch.elapsedMilliseconds.toString()+" COMPLETE!!!!");


  exit(0);
}