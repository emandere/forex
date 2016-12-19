import 'dart:isolate';

void main(List<String> args, SendPort replyTo) {
  for(int i=0;i<10000000000;i++)
  {
     var x = 1+2;
  }
  replyTo.send(args[0]+" balalalal222");
}