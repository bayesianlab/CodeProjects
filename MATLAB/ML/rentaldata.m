clear;
clc;
importrental;
Data = table2array(rentaldata);
[r,c] = size(Data);
rDno = Data(:,3)./Data(:,2);
s = Data(:,4);
d = Data(:,5);
srInt = s.*rDno;
girlInt = ( 1- s) .*rDno;
sdInt = s.*d;
girldInt = (1-s).*d;
c = ones(r, 1);
y = Data(:,6);
X = [c, srInt, girlInt, sdInt,girldInt];
XpXinv = inv(X'*X);
Mles =  XpXinv* X'*y;
resids = y - X*Mles;
res2 = resids'*resids;
sHat = res2/(r);
[~,J] = size(X);
J = J + 1;
V = zeros(J, J);
V(1,1) = 2*(sHat^2)/r;
V(2:J, 2:J) = sHat * XpXinv;
a = [0,-inf, 0, 0, -inf, -inf]';
b = [inf,inf, inf, inf, 0, 0]' ;
mu = [sHat, Mles']'
V
b0 = zeros(J-1,1);
B0 = eye(J-1);
a0 = 3;
d0 =5;
init = zeros(J,1);

C = chol(V, 'lower');
Cinv = inv(C);

s = 10;
alpha = a- mu;
beta = b - mu;
alpha(1) = Cinv(1,1)*alpha(1);
alpha(2:J) = -Inf;
beta(1:J) = Inf;

simresults = zeros(s,5);
N = 100;
bn = max([floor(.1*N), 1]);

% ghkT(a,b,mu,V,J+1,25)
% tmultnormrndEta(a,b,mu,V,100)
for i = 1:s
%     simresults(i,1) = ask(a,b, mu,V,y,X, N, bn, 100, b0,B0,a0,d0);
%     simresults(i,2) = ark(a,b,mu,V, y, X, N, b0, B0, a0, d0);
    simresults(i,3) = imp(a,b, mu,V,y,X, N, bn, b0,B0,a0,d0);
%     imp(a,b, mu,V,y,X, N, bn, b0,B0,a0,d0);
    simresults(i,4) = crt(a,b,mu,V,y,X,N, bn,b0,B0,a0,d0);
%     simresults(i,5) = crb(a,b,mu,V,y,X, N, bn, N, bn, init, b0,B0,a0,d0);
%     impT(a,b, mu,V, 6, y,X, N,  b0,B0,a0,d0)
    fprintf('\n')
end



% mean(simresults,2);
% std(simresults);


