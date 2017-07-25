function [ alpha, beta] = normalizeConstraints( a,b,mu,J )
unos = ones(J,1);
if a==-Inf && b ==Inf
    alpha = unos.*-Inf;
    beta= unos.*Inf;
elseif b == Inf
    alpha = (unos.*a) - mu';
    beta= unos.*Inf;
elseif a == -Inf
    alpha = (unos.*a)-Inf;
    beta = (unos.*b) - mu';
else
    beta = (unos.*b) - mu';
    alpha = (unos.*a) - mu';
end 
end

