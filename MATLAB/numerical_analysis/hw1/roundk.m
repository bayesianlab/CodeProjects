function[rounded] = roundk(x, n)
rounded = round( x * 10^n ) / 10^n;
