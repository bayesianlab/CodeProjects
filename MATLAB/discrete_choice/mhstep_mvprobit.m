function [W, D, R] = mhstep_mvprobit(w0,W0)
W  = .1*wishrnd(W0, w0);
D = diag(sqrt(diag(W)));
Dinv = inv(D);
R = Dinv*W*Dinv;
end

