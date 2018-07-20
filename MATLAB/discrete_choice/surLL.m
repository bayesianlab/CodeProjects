function [LL] = surLL(y, mu, Sigma)
% Computes Log Likelihood of SUR model
[r,N] = size(y);
y = y';
mu = mu';
LL = 0;
for i = 1 : N
    LL = LL + logmvnpdf(y(i,:), mu(i,:), Sigma);
end

end

