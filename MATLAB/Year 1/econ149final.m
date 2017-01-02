e = 29;
s = 30;
r = .05;
sigma = .25
s0 = 30 - .5*exp(-.05*1.5)
d1 = (log(s0/e) + (.05 + (sigma^2)/2)*(.3333) )/ (sigma * sqrt(.3333))
d2 = d1 - sigma*sqrt(.3333)
s0*normcdf(d1) - e*exp(-.05*(.3333))*normcdf(d2)
