import 'package:parallel/parallel.dart';
main(List<String> arguments) async
{
  int count = 1;
  if(arguments.isNotEmpty)
    count = int.parse(arguments[0]);


  Stopwatch stopwatch = new Stopwatch();
  stopwatch.start();
  for(int i=0;i<count;i++)
  {
    longloop(1);
  }
  stopwatch.stop();
  print(stopwatch.elapsedMilliseconds.toString());

  Stopwatch stopwatch2 = new Stopwatch();
  stopwatch2.start();
  await parallel(new List<int>.generate(count,(i)=>i+1)).pmap(longloop).toList();
  stopwatch2.stop();

  print(stopwatch2.elapsedMilliseconds.toString());
}

longloop(int i)
{
   int k=0;
   for(int i=0;i<10000000000;i++)
   {
      k++;
   }
   print(k.toString());
}