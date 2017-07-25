function [ alpha, beta ] = standardizedConstraints( a,b, lowerChol, mu, J)
unos = ones(J,1);
if a==-Inf && b ==Inf
    alpha = unos.*-Inf;
    beta= unos.*Inf;
elseif b == Inf
    alpha = lowerChol\( (unos.*a) - mu');
    beta= unos.*Inf;
elseif a == -Inf
    alpha = unos.*-Inf;
    beta = lowerChol\( (unos.*b) - mu');
else
    beta = lowerChol\ ((unos.*b) - mu');
    alpha = lowerChol\( (unos.*a) - mu');
end 

end

