clear; clc;




N = 2000;
Sims = 1;
batches = 1;
seed = 101;
% rng(seed)
coefs = unifrnd(0,1,40,1);
c=coefs(1:3);
fprintf('Coefs\n')
fprintf('======\n')
fprintf('%.2f\n', c)
% importanceMLSimulation(N, c, Sims, batches, seed)
% crtMLSimulations(N, c, Sims, batches,seed)
% crbMLSimulator(N, c, Sims, batches,seed)
% arkMLSimulator(N, c, Sims, batches, seed)
% askMLSimulator(N, c, Sims, batches,seed)

% fprintf('\n')
% c = coefs(5:12);
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
c = coefs(25:40);
% fprintf('Coefs\n')
% fprintf('======\n')
% fprintf('%.2f\n', c)
% fprintf('\n')
% importanceMLSimulation(N, c, Sims, batches, seed)
% crtMLSimulations(N, c, Sims, batches,seed)
% crbMLSimulator(N, c, Sims, batches,seed)
% arkMLSimulator(N, c, Sims, batches, seed)
% askMLSimulator(N, c, Sims, batches,seed)

exppdf(0:.1:2, .5)
figure(1)
hist(exprnd(.5, 1000,1))
figure(2)
hist(shiftexprnd(2, 1, 1000))
shiftexppdf(2, 1, 1:.1:2)