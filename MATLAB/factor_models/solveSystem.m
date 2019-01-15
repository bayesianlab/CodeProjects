function [answ, diagL, offdiagL] = solveSystem(P, x)
%% Solves system of type  eta = P^-1 x
%  P eta = x and cholesky of P = LU 
% LU eta = x first solve by forward sub. then backward sub. 
[L,p] = chol(P, 'lower');
if p ~= 0
    
else
    diagL = diag(L);
    offdiagL = tril(L, -1);
    offdiagU = offdiagL';
    T = size(L,1);
    soln = zeros(T,1);
    answ = zeros(T,1);
    for i = 1:T
        soln(i) = (x(i)-offdiagL(i,:)*soln)/ diagL(i);
    end
    for i = T:(-1):1
        answ(i) = (soln(i) - offdiagU(i,:)*answ)/diagL(i);
    end
end
end

