function [ Sprecision ] = kowStatePrecision(stackedTransitions,  stateVariance, T )
k = length(stackedTransitions);
Tmlag = T- 1;
Phi = -diag(stackedTransitions);
H = kron(spdiags(ones(T,1),-1, T, T), Phi);
H = H + speye(k*T,k*T);
sv = repmat(1/stateVariance, k*Tmlag);
Sprecision = [[diag(1./(1-stackedTransitions.^2)), sparse(k, k*Tmlag)];...
                spdiags(sv, k, k*Tmlag, k*T)];
Sprecision=H*Sprecision*H';
end

