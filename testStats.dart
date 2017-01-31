import 'dart:math';
import 'dart:collection';
import "package:collection/collection.dart";
/*main()
{
    /*List<double> x = new List<double>.generate(100,(i)=>i+1.0);
    int step = 10;
    for(int i=step;i<x.length;i++)
    {
        print(StdDev(x.sublist(i-step, i)).toString());
        print(BollingerUpper(x.sublist(i-step, i)).toString());
        print(BollingerLower(x.sublist(i-step, i)).toString());
        print(Average(x.sublist(i-step, i)).toString());


    }*/

    List<double> x = new List<double>.generate(100,(i)=>1.0-i);
    print(Slope(x).toString());

}*/
double BollingerUpper(List<double> x)
{
    double val = x.last;
    return val + 2* StdDev(x);
}
double BollingerLower(List<double> x)
{
    double val = x.last;
    return val - 2* StdDev(x);
}
double Average(List<double> x)
{
    double sum = x.reduce((t,e)=>t+e);
    double xavg = sum / x.length;
    return xavg;
}
double StdDev(List<double> x)
{
    double sumsquared = x.map((t)=>t*t)
                         .reduce((t,e)=>t+e);
    double stdDev = sqrt((sumsquared/x.length) - (Average(x)*Average(x)));
    return stdDev;
}

double Slope(List<double> y)
{
    var x = new List<double>.generate(y.length,(int index)=>index.toDouble()+1.0);
    double AverageX = Average(x);
    double AverageY = Average(y);

    double numerator = new IterableZip([x,y])
                        .map((t)=>(t[0]-AverageX)*(t[1]-AverageY))
                        .reduce((t,e)=>t+e);

    double denominator = x.map((t)=>pow((t-AverageX),2))
                       .reduce((t,e)=>t+e);

    return numerator / denominator;
}