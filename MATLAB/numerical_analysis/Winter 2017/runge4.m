function [ yt ] = runge4( tSpan, y0, fnq, h )
[nEqns,~] = size(y0);
ti = tSpan(1);
yi = y0;
storageSize = nEqns + 1;
yt = zeros((tSpan(2)/h), storageSize);
yt(1, 2:storageSize) = y0';
yt(1,1) = ti;
c = 1;
while ti < tSpan(2)
    c = c + 1;
    k1 = h*fnq(ti, yi);
    k2 = h*fnq(ti + .5*h, yi + .5*k1);
    k3 = h*fnq(ti + .5*h, yi + .5*k2);
    ti = ti + h;
    yt(c, 1) = ti;
    k4 = h*fnq(ti, yi + k3);
    yi = yi + .16666666667 * (k1 + 2*k2 + 2*k3 + k4);
    if sum(yi > 10^15) >= 1
        disp('Error, function going to infinity')
        disp(yt)
        yt = -1;
        break
    end
    yt(c, 2:storageSize) = yi';
end
end

