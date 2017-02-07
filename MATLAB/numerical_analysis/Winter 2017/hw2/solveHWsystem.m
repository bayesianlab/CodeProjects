function [ constants, eigenvalues ] = solveHWsystem( )
y(1,1) = 52.29;
y(2,1) = 83.82;
A = [-5,3;100,-301];
[K, eigenvalues] = eig(A);
c1c2 = linsolve(K, y);
constants = c1c2'.*K; 
end

