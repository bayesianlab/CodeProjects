function [ S ] = computeS123(CurrentObsModel, variancei, T)
   % Compute S1,S2,S3
S = zeros(T,T,3);
for k = 1:3
    p = full(spdiags([ones(T,1).*(-CurrentObsModel(k)), ones(T,1),...
        ones(T,1).*(-CurrentObsModel(k))],[-1,0],T,T));
    H = ones(T,1).*variancei;
    H = diag(H);
    S(:,:,k) = p*H*p';
end
end

