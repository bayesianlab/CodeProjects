function [DataCell] = MLFtimebreaks(K, T, timeBreak, identification)

nFactors = 1;

InfoCell = cell(1);
InfoCell{1,1} = [1,K];
xcols = 3;
Xt = normrnd(0,1, K*T, xcols);
Xt(:,1) = ones(K*T,1);

beta = .4.*ones(xcols, 1);

gam = unifrnd(.5,.6,nFactors,1);
stateTransitionsAll = gam'.*eye(nFactors);
speyeT = speye(T);

S = kowStatePrecision(stateTransitionsAll, ones(nFactors,1), T) \ speyeT;
Factor = mvnrnd(zeros(nFactors*T,1), S);
Factor = reshape(Factor,nFactors,T);

Gt1 = zeros(K,1);
Gt2 = unifrnd(.7,1,K,1);
Gt2(1) = 1;

mu1 = zeros(K,timeBreak);
mu2 = Gt2*Factor(timeBreak+1:end);
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


end

