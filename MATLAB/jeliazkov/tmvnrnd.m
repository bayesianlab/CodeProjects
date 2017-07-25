function [ sample ] = tmvnrnd( a,b, mu,sigma,N,burnin )
% Geweke 1991.  Draws from a truncated multivariate normal
% distribution.
% 
J = length(mu);
H = inv(sigma);
conditionalVars = diag(H);
yDim = 1:J;
sample = zeros(N, 3, J);
sample(1,1,:) = mu;
notj = notJindxs(J);
[alpha,beta] = normalizeConstraints(a,b,mu,J) ;
for n = 2:(N)
    for j = yDim
        tindex = notj(j,:);
        Hxx = conditionalVars(j);
        Hxy = H(j, tindex);
        sigmaxx = sqrt(Hxx^(-1));
        xNotj = squeeze(sample(n-1, 1, tindex));
        muj = -(1/Hxx)*Hxy*xNotj;
        sample(n, :, j) = [tnormrnd(alpha(j),beta(j), muj, sigmaxx), muj, sigmaxx];
    end
end
sample = sample(burnin+1:N,:,:);
sample
end
