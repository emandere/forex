import 'dart:math';
/*main()
{
    List<double> x = new List<double>.generate(100,(i)=>i+1.0);
    int step = 10;
    for(int i=step;i<x.length;i++)
    {
        print(StdDev(x.sublist(i-step, i)).toString());
        print(BollingerUpper(x.sublist(i-step, i)).toString());
        print(BollingerLower(x.sublist(i-step, i)).toString());
        print(Average(x.sublist(i-step, i)).toString());
    }
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