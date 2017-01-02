function [ outputVec ] = evalPoints( X_is, coefs, vals  )
nOuts = length(vals);
outputVec = zeros(nOuts,1);
c = length(X_is);
n = length(coefs);
if (c < n-1) || (c >=n)
    disp('Error, to many or too few points.')
    outputVec = '-1'; 
    return
end 
for i = 1:nOuts
    outputVec(i) = nMult(X_is, coefs, vals(i));
end
end

