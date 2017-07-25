clear; clc;



rng(9)
N = 1000;
Sims = 20;
batches = 2;
seed = 101;
% rng(seed)
coefs = unifrnd(0,1,40,1);
c=coefs(1:2);
fprintf('Coefs\n')
fprintf('======\n')
fprintf('%.2f\n', c)
importanceMLSimulation(N, c, Sims, batches, seed)
crtMLSimulations(N, c, Sims, batches,seed)
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



X = normrnd(1,1,N,8);
er = normrnd(0,.5,N,1);
y = X*c + er;
XpX = X'*X;
XpXinv = (XpX)^(-1);
Xpy = X'*y;
bMLE = XpX^(-1) * Xpy;
e = y - X*bMLE;
sSqd = (e'*e)/(N-8);  
thetaMLE = [sSqd; bMLE];
empty = zeros(8,1);
invFisher = [(2*sSqd^2)/N, empty' ;...
        empty, sSqd.*XpXinv];

[J, ~] = size(invFisher);
dex = notJindxs(J) ; 
H = inv(invFisher);
h = diag(H).^(-1);
sigNoti = sqrt(h);
x = zeros(10,J);
x(1,:) = thetaMLE;
a = zeros(1, length(thetaMLE)) ;
a(1) =.5;
b = Inf.*ones(1,length(thetaMLE));



% thetaMLE'
nj = notJindxs(J);
% sample = zeros(10, J);
% sample(1,:) = thetaMLE;
% for i = 2:20
% for j = 1:J
%     Hjnotj = H(j, nj(j,:));
%     Hjj = H(j,j);
%     xnot = sample(i-1, :);
%     munotj = conditionalMeanMVN(thetaMLE(j), Hjj, Hjnotj, xnot, thetaMLE(nj(j,:)))
%     
% 
% end
% end


L = chol(invFisher, 'lower');
invL = inv(L);
a = zeros(J,1);
b = Inf.*ones(J,1);
alpha = a - invL*thetaMLE;
m = 10;
H = inv(invFisher);
x = (L*truncNormStandardized(alpha, b, m, J)' + thetaMLE)';
mu = zeros(m,J);
for i = 1:m
    for j = 1:J
        tnj = nj(j,:);
        mu(i,j) =thetaMLE(j) - (1/H(j,j))*H(j,tnj)*(x(i, tnj)' - thetaMLE(tnj)); 
    end
end
% crtML(0,Inf, thetaMLE', invFisher, 100,10, thetaMLE')



