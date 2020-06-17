clear;clc;
% importspy
% importspxdata
% 
% y=table2array(probity(:,2:end))';
% y = y(:,1:5:size(y,2));
% spx = table2array(spx(:,2:end));
% spx = spx(1:5:size(spx,1), :);
% common = spx(:,1:3);
% peratios = spx(:, 4:end);
% [K,T] = size(y);
% dimX = size(common,2) + 1;
% colsX = 1:dimX;
% X = zeros(K*T,dimX-1);
% fillX = 1:K;
% tempX = X(1:K, :);
% 
% f = 1:K;
% for t = 1:T
%     s= f + K*(t-1);
%     X(s,:)=repmat(common(t,:), K,1);
% end
% X = [ones(K*T,1),X, peratios(:)];
% 
% X(:,2:end) = (X(:,2:end)-mean(X(:,2:end),1))./std(X(:,2:end),1);
% DataCell{1} = y;
% DataCell{2} = X;
% InfoCell{1} = [1,K];
% DataCell{3} = InfoCell;
% save('DataCell', 'DataCell')

load('DataCell')
Sims =10;
bn =1 ;
cg =0;
yt = DataCell{1,1};
Xt = DataCell{1,2};
InfoCell = DataCell{1,3};
[K,T] = size(yt);
[~, dimX] = size(Xt);
levels = size(InfoCell,2);
nFactors =  sum(cellfun(@(x)size(x,1), InfoCell));
lags=1;

v0= 6
r0 = 8
s0 = 6
d0 = 8
[Ey, Vy]=invGammaMoments(.5*v0, .5*r0)
[Ey, Vy] =invGammaMoments(.5*s0, .5*d0)
a0=1
A0 = 1
g0 = zeros(1,lags)
G0=diag(fliplr(.5.^(0:lags-1)));

beta0 = zeros(dimX,1);
B0 = 1.*eye(dimX);

initStateTransitions = zeros(nFactors,lags);
[Identities, ~, ~] = MakeObsModelIdentity( InfoCell);
initobsmodel = ones(K,levels);
initObsPrecision = 1./var(yt,[],2);
initFactorVar = ones(nFactors,1);
initFactor = normrnd(0,1,nFactors,T);
[Output] =GeneralMvProbit(yt, Xt, Sims, bn, cg, beta0, B0,g0, G0,...
    a0, A0, initFactor, InfoCell);

storeBeta=Output{1};
storeFt=Output{2};
storeSt=Output{3};
storeOm=Output{4};
storeD=Output{5};

fhat = mean(storeFt,3);