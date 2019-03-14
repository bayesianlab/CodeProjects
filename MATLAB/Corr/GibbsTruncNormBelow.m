function [zdraws] = GibbsTruncNormBelow(a, mu, Covariance, Sims, burnin, varargin)
K = size(Covariance,1);
H = Covariance\eye(K);
h = sqrt(diag(H));
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
        select = notk(notk~= k);
        cmean = vterms(k,:)*ztemp(select)';
        alpha = (a(k) - cmean)/h(k);
        epsilon = truncatedBelow(alpha,0, 1);
        ztemp(k) = cmean + h(k)*epsilon;
    end
    zdraws(t,:) = ztemp;
end
zdraws = zdraws(burnin+1:Sims,:);
zdraws = mu +zdraws;
end

