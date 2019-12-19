function [DataCell] = MLFtimebreaks(K, T, timeBreak)

nFactors = 1;
InfoCell = cell(1);
InfoCell{1,1} = [1,K];
xcols = 3;
Xt = normrnd(5,2.5, K*T, xcols);
Xt(:,1) = ones(K*T,1);

beta =.4.*ones(xcols, 1);
% beta=unifrnd(-.5, .5, xcols,1);
gam = .85.*ones(nFactors,1);
stateTransitionsAll = gam'.*eye(nFactors);
speyeT = eye(T);
[iP, ssState] =initCovar(stateTransitionsAll);
Si = FactorPrecision(ssState, iP, 1./(.5.*ones(nFactors,1)), T)\ speyeT;
Factor = mvnrnd(zeros(nFactors*T,1), Si);
Factor = reshape(Factor,nFactors,T);


Gt1 = unifrnd(-.05, .05, K,1);
Gt2 = ones(K,1);
Gt2(1) = 1;
mu1 = Gt1*Factor(1:timeBreak);
mu2 = Gt2*Factor((timeBreak+1):end);
m1 = Xt(1:(timeBreak*K),:)*unifrnd(-.05,.05, xcols,1);
m2 = Xt( (timeBreak*K +1):end,:)*beta;
m = reshape([m1;m2],K,T);
% m=reshape(Xt*beta,K,T);
MU = [mu1,mu2] + m;
yt = MU + normrnd(0,1,K,T);



DataCell = cell(1,7);
DataCell{1,1} = yt;
DataCell{1,2} = Xt;
DataCell{1,3} = InfoCell;
DataCell{1,4} = Factor;
DataCell{1,5} = 0;
DataCell{1,6} = gam;
DataCell{1,7} = Gt1;
DataCell{1,8} = Gt2;

save('TimeBreakSimData/totaltime.mat', 'DataCell')

% yt1 = yt(:,1:timeBreak);
% [K,t1] = size(yt1);
% Xt1 = Xt(1:(K*timeBreak),:);
% 
% DataCell{1,1} = yt1;
% DataCell{1,2} = Xt1;
% DataCell{1,3} = InfoCell;
% 
% save('time1.mat', 'DataCell')
% 
% yt2 = yt(:,(timeBreak+1) : end);
% [K,t2] = size(yt2);
% Xt2 = Xt( (K*timeBreak+1): end,:);
% 
% DataCell{1,1} = yt2;
% DataCell{1,2} = Xt2;
% DataCell{1,3} = InfoCell;
% 
% save('time2.mat', 'DataCell')
end

