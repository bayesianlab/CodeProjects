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
a = [0,-inf, 0, 0, -inf, -inf]'
b = [inf,inf, inf, inf, 0, 0]'  
mu = [sHat, Mles']';
b0 = zeros(J,1);
B0 = eye(J);
a0 = 6;
d0 =12;
init = zeros(J+1,1);

x = normrnd(0,1,10,3);
autocor(x,1);
VL = chol(V, 'lower')
VLinv= inv(VL)


alpha = a - mu;
beta = b - mu;
alpha(1) = VLinv(1,1)*alpha(1)
alpha(2:J+1) = -Inf
beta(1:J+1) = Inf
tmultnormrndEta(alpha,beta,mu,V,10, zeros(J+1,1))

tmultnormrnd(a,b,mu,V,10,zeros(J+1,1))
% adaptiveSampler(a,b,mu,V,100,10,10)
% ask(a,b,mu,V,y,X,1000,100, 100, b0,B0,a0,d0)
crt(a,b,mu,V,y,X,1000,100,b0,B0,a0,d0)
crb(a,b,mu,V,y,X, 1000, 100, 1000,100, init, b0,B0,a0,d0)




