function [Precision] = kowPrecision(stateTransition, T)
initvar = 1/(1-stateTransition^2);
D = ones(T,1);
D(1) =initvar;
Sinv = spdiags(D.^(-1), 0, T,T);
H = spdiags(ones(T,1).*(-stateTransition), -1, T,T) + speye(T,T);
Precision = H'*Sinv*H ;
end

