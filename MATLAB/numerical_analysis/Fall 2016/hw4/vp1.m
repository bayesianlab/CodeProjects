function  dydt = vp1(t,y )
dydt = zeros(2,1);
dydt(1) = y(2);
dydt(2) = (1 - cos(t - .75*sin(t))) - .5*y(2) - y(1);
end

