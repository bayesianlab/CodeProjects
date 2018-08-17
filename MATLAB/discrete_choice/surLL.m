function [LL] = surLL(y, mu, Sigma)
% Computes Log Likelihood of SUR model
[r,N] = size(y);
LL = 0;
for i = 1 : r
    LL = LL + logmvnpdf(y(i,:), mu(i,:), Sigma);
end

end

