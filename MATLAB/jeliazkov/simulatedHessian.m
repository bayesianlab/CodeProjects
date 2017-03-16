function [ Hessian ] = simulatedHessian(beta, eps, del)
h = eye(length(beta)).*del;

LL0 = ARmethodSimulateMoments(beta, eps);

LLb1b1P = ARmethodSimulateMoments(beta+h(:,1), eps);
LLb1b1M = ARmethodSimulateMoments(beta-h(:,1), eps);
fxx = (LLb1b1P + LLb1b1M - 2*LL0) / (del^2);

LLb2b2P = ARmethodSimulateMoments(beta+h(:,2), eps);
LLb2b2M = ARmethodSimulateMoments(beta-h(:,2), eps);
fyy = (LLb2b2P + LLb2b2M - 2*LL0) / (del^2);

LLb1b2PP =  ARmethodSimulateMoments(beta+diag(h), eps);
LLb1b2PM =  ARmethodSimulateMoments(beta+h(:,1) - h(:,2), eps);
LLb1b2MP =  ARmethodSimulateMoments(beta-h(:,2) + h(:,1), eps);
LLb1b2MM =  ARmethodSimulateMoments(beta-diag(h), eps);

fxy = (LLb1b2PP - LLb1b2PM - LLb1b2MP + LLb1b2MM) / (4*del^2);

Hessian = -[fxx, fxy; fxy, fyy];

end

