function [ derivLL ] = simulatedDerivative(beta, eps, del)
r = length(beta);
h = eye(r).*del;
derivLL = zeros(r,1);
for i = 1:r
    LLup = ARmethodSimulateMoments(beta+h(:,i),eps);
    LLdown = ARmethodSimulateMoments(beta-h(:,i),eps);
    derivLL(i) = -(LLup - LLdown )/(2*del);
end
end

