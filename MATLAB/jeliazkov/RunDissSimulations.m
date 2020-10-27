% Run Dissertation Simulations
clear;clc;
T = [1,1; 2,1; 2,2; 2,3; 3,1;1,4; 2,4; 2,5; 2,6; 3,4];
LT=size(T,1);
N = 100;
K = 3;
X = normrnd(1,1, N,K);
y = X*[.25;.45; .01]  + normrnd(0,1, N,1);
R = 1000;
Constraints = [1,1,1];
saveml = zeros(size(T,1), R);
Sims = 2000;
bn = 200;
for t = 1:LT
    simtype = T(t,:);
    for reps = 1:R
        mltype = simtype(1);
        samplerType = simtype(2);
        [~, ~,mlR] = RestrictedLR_Gibbs(Constraints, y, X,...
            zeros(K,1), 100*eye(K), 6, 12, Sims, bn, samplerType, mltype);
        saveml(t,reps) = mlR;
    end
end
save('simulation_results')