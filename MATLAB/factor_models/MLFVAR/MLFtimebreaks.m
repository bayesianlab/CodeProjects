function [DataCell] = MLFtimebreaks(K, t1,t2, identification)

nFactors = 1;
T = t1 + t2;
InfoCell = cell(1);
InfoCell{1,1} = [1,K];
xcols = 3;
Xt = normrnd(0,1, K*T, xcols);
Xt(:,1) = ones(K*T,1);

beta = .4.*ones(xcols, 1);

gam = unifrnd(.5,.6,nFactors,1);
stateTransitionsAll = gam'.*eye(nFactors);
speyet1 = speye(t1);

S1 = kowStatePrecision(stateTransitionsAll, ones(nFactors,1), t1) \ speye(nFactors*t1);
Factor1 = mvnrnd(zeros(nFactors*t1,1), S1);
Factor1 = reshape(Factor1,nFactors,t1);
S2 = kowStatePrecision(stateTransitionsAll, ones(nFactors,1), t2)\speye(nFactors*t2);
Factor2 = mvnrnd(zeros(nFactors*t2,1), S2);
Factor2 = reshape(Factor2,nFactors,t2);

% Gt1 = unifrnd(.80,1,K,1);
% Gt1 = ones(K,1).*.5;
Gt1 = zeros(K,1);
% Gt1(1) = 1;
mu1 = Gt1*Factor1;
yt1 = mu1 + normrnd(0,1,K,t1);

% Gt2 = unifrnd(-.05,.05,K,1);
Gt2 = ones(K,1).*.5;
% Gt2 = zeros(K,1);
Gt2(1) = 1;
mu2 = Gt2*Factor2;

yt2 = mu2 + normrnd(0,1,K,t2);

yt = [yt1,yt2] + reshape(Xt*beta, K,T);

DataCell = cell(1,7);
DataCell{1,1} = yt;
DataCell{1,2} = Xt;
DataCell{1,3} = InfoCell;
DataCell{1,4} = Factor1;
DataCell{1,5} = 0;
DataCell{1,6} = gam;
DataCell{1,7} = Gt1;
DataCell{1,8} = Gt2;


end

