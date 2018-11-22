function [ P0 ] = kowMakeStateSpace(ArParams,  stateVariance )
[k, lags] = size(ArParams);

% State space representation 
bottom = [eye(lags-1),zeros(lags-1,1)];
Phi = [ArParams;bottom]
R = [1; zeros(lags-1,1)];
RRp = R*R';
ImGamma = eye(lags^2) - kron(Phi,Phi);

P0 = reshape(ImGamma\RRp(:), lags, lags);
end

