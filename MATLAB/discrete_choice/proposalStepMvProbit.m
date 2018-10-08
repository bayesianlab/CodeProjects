function [W, D, R] = proposalStepMvProbit(w0,W0)

W  = wishrnd(W0, w0)./w0;
D = diag(W);
Dinvhalf = diag(D.^(-.5));
D= diag(D);
R = Dinvhalf*W*Dinvhalf;
end

