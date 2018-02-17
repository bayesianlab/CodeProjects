function [sample, gwk] = warmup(a,b, mu,Sigma, burnin)
[J,~] = size(Sigma);
sample = zeros(burnin,J);
gwk = 0;
if unifrnd(0,1) < .5

    sample(1:burnin, :) = tmultnormrnd(a,b,mu, Sigma, burnin, zeros(J,1));
    gwk = 1;
else 
    sample(1:burnin, :) = tmultnormrndEta(a,b,...
        mu, Sigma, burnin);
end
end

