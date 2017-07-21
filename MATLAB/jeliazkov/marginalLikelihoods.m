clear; clc;




N = 2000;
Sims = 1;
batches = 1;
seed = 101;
% rng(seed)
coefs = unifrnd(0,1,40,1);
c=coefs(1:3);
fprintf('Coefs\n')
fprintf('======\n')
fprintf('%.2f\n', c)
% importanceMLSimulation(N, c, Sims, batches, seed)
% crtMLSimulations(N, c, Sims, batches,seed)
% crbMLSimulator(N, c, Sims, batches,seed)
% arkMLSimulator(N, c, Sims, batches, seed)
% askMLSimulator(N, c, Sims, batches,seed)

% fprintf('\n')
c = coefs(5:12);
% fprintf('Coefs\n')
% fprintf('======\n')
% fprintf('%.2f\n', c)
% fprintf('\n')
% importanceMLSimulation(N, c, Sims, batches, seed)
% crtMLSimulations(N, c, Sims, batches,seed)
% crbMLSimulator(N, c, Sims, batches,seed)
% arkMLSimulator(N, c, Sims, batches, seed)
% askMLSimulator(N, c, Sims, batches,seed)

% fprintf('\n')
% c = coefs(13:24);
% fprintf('Coefs\n')
% fprintf('======\n')
% fprintf('%.2f\n', c)
% fprintf('\n')
% importanceMLSimulation(N, c, Sims, batches, seed)
% crtMLSimulations(N, c, Sims, batches,seed)
% crbMLSimulator(N, c, Sims, batches,seed)
% arkMLSimulator(N, c, Sims, batches, seed)
% askMLSimulator(N, c, Sims, batches,seed)

% fprintf('\n')
% c = coefs(25:40);
% fprintf('Coefs\n')
% fprintf('======\n')
% fprintf('%.2f\n', c)
% fprintf('\n')
% importanceMLSimulation(N, c, Sims, batches, seed)
% crtMLSimulations(N, c, Sims, batches,seed)
% crbMLSimulator(N, c, Sims, batches,seed)
% arkMLSimulator(N, c, Sims, batches, seed)
% askMLSimulator(N, c, Sims, batches,seed)

% x = robertRandVars(.15, Inf, 1000, 1)
% mean(x*.007 - .2)
% std(x*.007 - .2)


rng(9);
X = normrnd(1,1,N,8);
er = normrnd(0,.5,N,1);
y = X*c + er;
XpX = X'*X;
XpXinv = (XpX)^(-1);
Xpy = X'*y;
bMLE = XpX^(-1) * Xpy;
e = y - X*bMLE;
sSqd = (e'*e)/(N-8);  
thetaMLE = [sSqd; bMLE]
empty = zeros(8,1);
invFisher = [(2*sSqd^2)/N, empty' ;...
        empty, sSqd.*XpXinv];



invFisher = sSqd.*XpXinv
size(invFisher)
thetaMLE = bMLE;
size(thetaMLE)
dex = notJindxs(8) ; 
H = inv(invFisher);
h = diag(H).^(-1)
x = zeros(10,8);
x(1,:) = thetaMLE'
for a = 2:5
for j = 1:8
    prec = H(j, dex(j, :));
    s = sqrt(h(j));
    xnot = x(a-1, dex(j,:));
    munot = thetaMLE(dex(j, :));
    cmu = thetaMLE(j) - (h(j).*prec *(xnot' - munot))
    x(a, j) = normrnd(cmu, s);
end
end
x

