function [answ] = matrixLinSysSolve(LowerCholesky, X)
C = size(X,2);
diagL = diag(LowerCholesky);
offdiagL = tril(LowerCholesky, -1);
offdiagU = offdiagL';
T = size(LowerCholesky,1);
soln = zeros(T,C);
answ = zeros(T,C);
for i = 1:T
    for c = 1:C
        soln(i,c) = (X(i,c)-offdiagL(i,:)*soln(:,c))./ diagL(i);
    end
end
for i = T:(-1):1
    for c = 1:C
        answ(i,c) = (soln(i,c) - offdiagU(i,:)*answ(:,c))/diagL(i);
    end
end
end

