function [W, D, R] = mhstep_mvprobit(w0,W0)
W  = wishrnd(W0, w0);
D = diag(W);
Dinvhalf = diag(D.^(-.5));
D= diag(D);
R = Dinvhalf*W*Dinvhalf;
end

