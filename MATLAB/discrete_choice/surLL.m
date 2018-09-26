function [LL] = surLL(y, mu, Sigma)
% Computes Log Likelihood of SUR model
LL = sum(log(mvnpdf(y, mu, Sigma)));
end

