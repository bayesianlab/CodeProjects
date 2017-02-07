function [ yt, dfnq ] = getInitialPoints( nPoints, tStart, y0, fnq, h )
% Returns nPoints number of points to kick off method
% yt is a vector with first column as the variable t, the others are
% the y's. Extra columns are the derivatives
if isrow(y0) == 1
    y0 = y0';
end 
[nEqns,~] = size(y0);
ti = tStart;
yi = y0;
storageSize = nEqns + 1;
dfnq = zeros(nPoints, nEqns);
yt = zeros(nPoints, storageSize);
yt(1, 2:storageSize) = y0';
dfnq(1,1:nEqns) = fnq(ti,y0)';
yt(1,1) = ti;
c = 0;
while c < nPoints
    c = c + 1;
    k1 = h*fnq(ti, yi);
    k2 = h*fnq(ti + .5*h, yi + .5*k1);
    k3 = h*fnq(ti + .5*h, yi + .5*k2);
    ti = ti + h;
    yt(c, 1) = ti;
    k4 = h*fnq(ti, yi + k3);
    yi = yi + .1666666666667 * (k1 + 2*k2 + 2*k3 + k4);
    if sum(yi > 10^15) >= 1
        disp('Error, function going to infinity')
        disp(yt)
        yt = -1;
        break
    end
    yt(c, 2:nEqns + 1) = yi';
    dfnq(c, 1:nEqns) = fnq(ti,yi)';
end
end