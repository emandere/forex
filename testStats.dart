import 'dart:math';
main()
{
    List<double> x = [1.0,2.0,3.0];
    print(StdDev(x).toString());
    print(BollingerUpper(x).toString());
    print(BollingerLower(x).toString());
}
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
    double sum = x.fold(0,(t,e)=>t+e);
    double xavg = sum / x.length;
    return xavg;
}
double StdDev(List<double> x)
{
    double sumsquared = x.fold(0,(t,e)=>t+(e*e));
    double stdDev = sqrt((sumsquared/x.length) - (Average(x)*Average(x)));
    return stdDev;
}