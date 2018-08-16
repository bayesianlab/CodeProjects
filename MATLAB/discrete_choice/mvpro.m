clear;
clc;
rng(5);

N = 1000;
K = 2;
c = ones(N,1);
Sigma = eye(K) +[0,.5;.5,0];
x1 = [c,normrnd(0,1, N,1)];
x2 = [c,normrnd(0, 1, N,2)];

T1 = kron(x1, eye(K));
T2 = kron(x2, eye(K));
T1 = [ T1(:,1), T1(:,3)];
T2 = [T2(:,2), T2(:,4), T2(:,6)];
surX = [T1,T2];
[nrow, ncol] = size(surX);
TrueB = [.3, -.5, -1.5, .6, .4]';
eps = mvnrnd(zeros(K,1), Sigma,N)';
mu = surX*TrueB;
vecz = mu + eps(:);
MLEs = inv(surX'*surX)*surX'*vecz;
sigmamle = (reshape(vecz,K,N)' - reshape(mu,K,N)')'*(reshape(vecz,K,N)' - reshape(mu,K,N)')./N;
D0inv = diag(1./sqrt(diag(sigmamle)));
MLER = D0inv*sigmamle*D0inv;
R0 = eye(2);
D0 = .1*inv(D0inv);
y = vecz > 0;
y = reshape(y,K,N);
mu = reshape(mu, K,N);

b0 = zeros(ncol, 1);
B0 = eye(ncol)*100;
wishartDf = 2;
proposalDf = wishartDf;

yz = reshape(vecz, K,N);

[bbar, Rbar, ar] = mv_probit(y, surX, MLEs, B0, wishartDf, ...
     D0, R0, 100, sigmamle);
MeanBeta = bbar';
disp(table(TrueB, MLEs, MeanBeta))

fprintf('Average Correlation Matrix: \n')
disp(Rbar)
fprintf('Accept reject rate MH: \n')
disp(ar)
fprintf('TrueSigma\n')
disp(Sigma)
fprintf('MLE Sigma\n')
disp(MLER)
fprintf('Sample Size\n')
disp(N)

