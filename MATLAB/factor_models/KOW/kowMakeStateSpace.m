function [ P0 ] = kowMakeStateSpace(ArParams,  stateVariance, T )
[k, lags] = size(ArParams);
Tmlag = T- lags;
% State space representation 
bottom = [eye(lags-1),zeros(lags-1,1)];
Phi = [ArParams;bottom];
R = [1; zeros(lags-1,1)];
RRp = R*R';
P0 = reshape((eye(lags^2) - kron(Phi,Phi))\RRp(:), lags, lags);
end

