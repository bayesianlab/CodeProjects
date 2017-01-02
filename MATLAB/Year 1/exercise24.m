function [] = exercise24()
%  i alpha = mu (1- sum rhoj) %
clc
eigenString =['Eigenvalues and eigenvectors'];
mu = 10;
rho = [1.2 -.3 0 0];
alpha = mu*(1 - sum(rho));
A = [1.2 -.3 0 0 alpha; 1 0 0 0 0; 0 1 0 0 0; 0 0 1 0 0;...
    0 0 0 0 1];
C = [1 0 0 0 0];
disp('PART I')
doublej(A, C'*C)
disp(eigenString)
[V,X] = eig(A)

% ii
mu = 10;
rho = [1.2 -.3 0 0];
alpha = mu*(1 - sum(rho));
A = [1.2 -.3 0 0 alpha; 1 0 0 0 0; 0 1 0 0 0; 0 0 1 0 0;...
    0 0 0 0 1];
C = [2 0 0 0 0];
disp('PART II')
doublej(A, C'*C)
disp(eigenString)
[V,X] = eig(A)

% iii
mu = 5;
rho = [0.9 0 0 0];
alpha = mu*(1 - sum(rho));
A = [.9 0 0 0 alpha; 1 0 0 0 0; 0 1 0 0 0; 0 0 1 0 0;...
    0 0 0 0 1];
C = [1 0 0 0 0];
disp('PART III')
doublej(A, C'*C)
disp(eigenString)
[V,X] = eig(A)

% iv
mu = 5;
rho = [.2 0 0 .2];
alpha = mu*(1 - sum(rho));
A = [0.2 0 0 .5 alpha; 1 0 0 0 0; 0 1 0 0 0; 0 0 1 0 0;...
    0 0 0 0 1];
C = [1 0 0 0 0];
disp('PART IV')
doublej(A, C'*C)
disp(eigenString)
[V,X] = eig(A)

% v
mu = 5;
rho = [.8 .3 0 0];
alpha = mu*(1 - sum(rho));
A = [0.8 .3 0 0 alpha; 1 0 0 0 0; 0 1 0 0 0; 0 0 1 0 0;...
    0 0 0 0 1];
C = [1 0 0 0 0];
disp('PART V')
doublej(A, C'*C)
disp(eigenString)
[V,X] = eig(A)
end