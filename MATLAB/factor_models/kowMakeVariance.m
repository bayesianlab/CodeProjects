function [ K ] = kowMakeVariance(  Phi, P0,  statevariance, T )

k = size(Phi,2);

H = full(spdiags([tril(ones(T,k).*Phi,0), ones(T,1)], [-k:0], T,T) );
Sinv = spdiags(ones(T,1).*(1/statevariance),0,T, T);
Sinv(1:k, 1:k) = P0;
K = H*Sinv*H';

end

