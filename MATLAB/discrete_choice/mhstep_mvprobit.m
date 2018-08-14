function [W, D, R] = mhstep_mvprobit(w0,W0)
W  = wishrnd(W0, w0);
D = diag(sqrt(diag(W)));
Dinv = diag(sqrt(1./diag(W)));
R = Dinv*W*Dinv;
end

