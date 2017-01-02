function  dydt = vp1(t,y )
y(2) = 0;
dydt =(1 - cos(t - .75*sin(t))) - .5*y(2) - y(1)



end

