%% ABC
% Dgp
clear;clc;
M = 100;
m = 100;
truep = .5;
y = binornd(M,truep, m,1);
sumy =sum(y);
sims = 100;
tol = 1e-2;
tstore = zeros(sims,1);
for i = 1:sims
    dist = tol+1;
    while dist > tol
      tstar = betarnd(1,1);
      ystar = binornd(M,tstar,M,1);
      dist = abs(sumy - sum(ystar))/M;
    end
    tstore(i,1) = tstar;
end
hist(tstore)