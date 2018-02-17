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
[~, J] = size(X);
V = zeros(J+1, J+1);
V(1,1) = 2*(sHat^2)/r;
V(2:(J+1), 2:(J+1)) = sHat * XpXinv;
a = [0,-inf, 0, 0, -inf, -inf]';
b = [inf,inf, inf, inf, 0, 0]' ;
mu = [sHat, Mles']'
b0 = zeros(J,1);
B0 = eye(J);
a0 = 6;
d0 =12;
init = zeros(J+1,1);

C = chol(V, 'lower');
Cinv = inv(C);

s = 1
alpha = a- mu;
beta = b - mu;
alpha(1) = Cinv(1,1)*alpha(1);
alpha(2:J+1) = -Inf;
beta(1:J+1) = Inf;
imp(a,b, mu,V,y,X,5, b0,B0,a0,d0)

simresults = zeros(s,4);
% for i = 1:s
%     simresults(i,1) = ask(a,b, mu,V,y,X,5000,500, 100, b0,B0,a0,d0);
%     simresults(i,2) = ark(a,b,mu,V, y, X, 5000, b0, B0, a0, d0);
%     simresults(i,3) = crt(a,b,mu,V,y,X,5000,500,b0,B0,a0,d0);
%     simresults(i,4) = crb(a,b,mu,V,y,X, 5000, 500, 5000, 500, init, b0,B0,a0,d0);
%     fprintf('\n')
% end
% simresults
% mean(simresults)
% std(simresults)


