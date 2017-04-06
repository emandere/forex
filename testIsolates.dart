import 'dart:isolate';
import 'dart:async';
import 'dart:core';
import 'dart:io';
main(List<String> arguments) async
{

  var experiments =[1,2,3,4,5,6,7,8,9,19,11,12,13,14,15,16,17,18,19,20,21,22,23,23,24,25,26,27,28,29];
  var cores = 9;
  print(chunk(cores,experiments));
  /*int count = 1;
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


  exit(0);*/
}


chunk(int count,List listToChunk)
{
  int step = listToChunk.length~/count;
  int remainder = listToChunk.length.remainder(count);
  int matchingList = listToChunk.length - remainder;
  var returnlist =[];
  step = step==0?1:step;

  for(int i=0;i<matchingList;i+=step)
  {
    var sublist = [];
    for (int j = i; j < i+step; j++)
    {
      sublist.add(listToChunk[j]);
    }
    returnlist.add(sublist);
  }

  var listpos =0;
  for(int i=matchingList;i<listToChunk.length;i++)
  {
    returnlist[listpos].add(listToChunk[i]);
    listpos++;
  }
  return returnlist;
}