function [LL] = surLL(y, mu, Sigma)
% Computes Log Likelihood of SUR model
[r,~] = size(y);
LL = 0;
for i = 1 : r
    LL = LL + log(mvnpdf(y(i,:), mu(i,:), Sigma));
end
end

