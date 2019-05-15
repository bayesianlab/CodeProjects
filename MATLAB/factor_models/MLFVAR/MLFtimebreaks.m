function [DataCell] = MLFtimebreaks(K, T, timeBreak, identification)

nFactors = 1;

InfoCell = cell(1);
InfoCell{1,1} = [1,K];
xcols = 3;
Xt = normrnd(0,1, K*T, xcols);
Xt(:,1) = ones(K*T,1);

beta = .4.*ones(xcols, 1);

gam = unifrnd(0, .2,nFactors,1);
stateTransitionsAll = gam'.*eye(nFactors);
speyeT = speye(T);

S = kowStatePrecision(stateTransitionsAll, ones(nFactors,1), T) \ speyeT;
Factor = mvnrnd(zeros(nFactors*T,1), S);
Factor = reshape(Factor,nFactors,T);

% Gt1 = unifrnd(.8,1, K,1);
% Gt1(1) = 1;
Gt1 = zeros(K,1);
Gt2 = unifrnd(.8,1,K,1);
Gt2(1) = 1;

mu1 = Gt1*Factor(1:timeBreak);

mu2 = Gt2*Factor((timeBreak+1):end);

MU = [mu1,mu2] + reshape(Xt*beta,K,T);
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

save('totaltime.mat', 'DataCell')

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

