function [zdraws] = Experimental(a, mu, Covariance, Sims, burnin, varargin)
K = size(Covariance,1);
H = Covariance\eye(K);
L = chol(Covariance, 'lower');
h = sqrt(1./diag(H));
Alpha = (a- mu)';
% Alpha = (a - mu)./h;
vterms = zeros(K,K-1);
notk = 1:K;
for k = 1:K
    select = notk(notk~= k);
    vterms(k,:) = -H(k,k)\H(k,select);
end

if nargin > 5
    ztemp = varargin{1,1};
else
    ztemp = zeros(1,K);
end
zdraws = zeros(Sims,K);
for t = 1:Sims
    for k = 1:K
        select = notk(notk~=k);
        cmean = vterms(k,:)*ztemp(select)';
        ztemp(k) = truncatedBelow(Alpha(k),cmean, h(k));
    end
    zdraws(t,:) = ztemp;
end
zdraws = zdraws(burnin+1:Sims,:);
zdraws =mu + zdraws;
end

