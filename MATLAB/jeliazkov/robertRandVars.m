function [ y ] = robertRandVars( mu, alpha, N, p )
z = shiftexprnd(mu, alpha, N, p);

if mu < alpha
    rv = exp(((-(alpha - z).^2))./2);
else
    rv = exp( ((mu - alpha).^2)./2) .* exp(-((alpha - z).^2)./2 );
end
u = unifrnd(0,1,N,p);
logicalVector = u <= rv;
len = sum(logicalVector);
y = -rv(logicalVector, :);
resample = N - len;
if resample >= 1
    y = vertcat(y, robertRandVars(mu, alpha, resample, p));
else
    return
end
end

