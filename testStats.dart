import 'lib/forex_stats.dart';
import 'package:collection/collection.dart';
main()
{
    List<double> x = [1.0,2.0,3.0];
    List<double> y = [3.0,1.0,2.0];

    print(RSI(new IterableZip([x,y])).toString());
}
