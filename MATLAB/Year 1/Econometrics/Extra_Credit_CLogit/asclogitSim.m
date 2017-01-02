% Simple simulation of mlogit

clear all; clc;
delete asclogitSim.diary
diary  asclogitSim.diary
tic;
seed = 1234;
rng(seed,'twister');

N       = 2e5;
T       = 5;
J       = 5;

% generate the data
X = [ones(N*T,1) 5+3*randn(N*T,1) rand(N*T,1) 2.5+2*randn(N*T,1)];
for j=1:J
	Z(:,:,j) = [3+randn(N*T,1) randn(N*T,1)-1 rand(N*T,1)];
end

% X coefficients
b(:,1) = [-0.15; 0.10; 0.50; 0.10];
b(:,2) = [-1.50; 0.15; 0.70; 0.20];
b(:,3) = [-0.75; 0.25;-0.40; 0.30];
b(:,4) = [ 0.65; 0.05;-0.30; 0.40];
b(:,5) = [ 0.75; 0.10;-0.50; 0.50];

% Z coefficients
bz = [.2;.5;.8];

% generate choice probabilities
dem = zeros(N*T,1);
for j=1:J
    u(:,j) = X*b(:,j)+Z(:,:,j)*bz;
	dem=exp(u(:,j))+dem;
end
for j=1:J
	p(:,j) = exp(u(:,j))./dem;
end

% use the choice probabilities to create the observed choices
draw=rand(N*T,1);
Y=(draw<sum(p(:,1:end),2))+...
  (draw<sum(p(:,2:end),2))+...
  (draw<sum(p(:,3:end),2))+...
  (draw<sum(p(:,4:end),2))+...
  (draw<sum(p(:,5:end),2));
tabulate(Y);

bAns = b(:)-repmat(b(:,J),J,1);
bAns = cat(1,bAns(1:(J-1)*size(X,2)),bz);
size(bAns)

disp(['Time spent on simulation: ',num2str(toc)]);

% Now estimate using mlogitBaseAltRestrict:
options=optimset('Disp','Iter','LargeScale','on','MaxFunEvals',2000000,'MaxIter',15000,'TolX',1e-8,'Tolfun',1e-8,'GradObj','on','DerivativeCheck','off','FinDiffType','central');
% startval = .05*rand((J-1)*size(X,2)+size(Z,2),1);
startval = bAns;
% bEst = fminunc('mlogitBaseAltRestrict',startval,options,[],Y,X,Z);
bEst = fminunc('clogit',startval,options,[],Y,X,Z);
[bEst bAns]
P = pclogit(bEst,Y,X,Z);
summarize(P);
diary off