function [ ll ] = marginalLogLikelihood( y, mu, a,FullSigma, Sdiag )
% S is the precision, Sdiag is diagaonal of precision. Needs work. 
% What is St?
K = size(FullSigma,1);
T = length(y)/K;
constant = K*T*log(2*pi);
index =1:K;
mahsum = zeros(T,1);
for t = 1:T
    select = index + (t-1)*K;
    Vtinv = woodburyInvert(FullSigma, a, Sdiag(t), a');
    demean = (y(select) - mu(select));
    mahsum = mahsum + demean'*Vtinv*demean + log(det(Vtinv));
end
ll = -.5*(constant + mahsum);
end

