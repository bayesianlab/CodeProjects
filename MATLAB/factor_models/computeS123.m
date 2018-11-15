function [ S ] = computeS123(StateTransitions, statevariance, T)
   % Compute S1,S2,S3
[r,c] = size(StateTransitions);
S = zeros(T,T,r);
onevec = ones(T, 3);
onevec(1,2) = 0 ;
onevec(1,3) = 0;
onevec(2,3) = 0;

for k = 1:r
    diagvec = [onevec.*StateTransitions(k,:), ones(T,1)];
    H = full(spdiags(diagvec,-c:0,T,T));
    V = ones(T,1).*(1/statevariance);
    V = diag(V);
    S(:,:,k) = H*V*H';
end
end

