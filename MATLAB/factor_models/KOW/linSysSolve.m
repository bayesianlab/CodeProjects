function [answ] = linSysSolve(LowerCholesky, x)
%% Solves system of type LowerCholesky*eta = x
diagL = diag(LowerCholesky);
offdiagL = tril(LowerCholesky, -1);
offdiagU = offdiagL';
T = size(LowerCholesky,1);
soln = zeros(T,1);
answ = zeros(T,1);
for i = 1:T
    soln(i) = (x(i)-offdiagL(i,:)*soln)/ diagL(i);
end
for i = T:(-1):1
    answ(i) = (soln(i) - offdiagU(i,:)*answ)/diagL(i);
end

end

