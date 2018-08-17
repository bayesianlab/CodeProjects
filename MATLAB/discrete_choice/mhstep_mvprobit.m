function [W, D, R] = mhstep_mvprobit(w0,W0)
W  = inv(wishrnd(W0, w0));
D = diag(diag(W));
Dinvhalf = inv(D).^.5;
R = Dinvhalf*W*Dinvhalf;
end

