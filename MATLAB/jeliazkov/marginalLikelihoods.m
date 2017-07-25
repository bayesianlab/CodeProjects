clear; clc;



rng(9)
N = 100;
Sims = 6;
batches = 3;
seed = 101;
% rng(seed)
coefs = unifrnd(0,1,40,1);
c=coefs(1:2);
% fprintf('Coefs\n')
% fprintf('======\n')
% fprintf('%.2f\n', c)
importanceMLSimulation(N, c, Sims, batches, seed)
crtMLSimulations(N, c, Sims, batches,seed)
crbMLSimulator(N, c, Sims, batches,seed)
% arkMLSimulator(N, c, Sims, batches, seed)
% askMLSimulator(N, c, Sims, batches,seed)

% fprintf('\n')
c = coefs(5:12);
% fprintf('Coefs\n')
% fprintf('======\n')
% fprintf('%.2f\n', c)
% fprintf('\n')
importanceMLSimulation(N, c, Sims, batches, seed)
crtMLSimulations(N, c, Sims, batches,seed)
crbMLSimulator(N, c, Sims, batches,seed)
% arkMLSimulator(N, c, Sims, batches, seed)
% askMLSimulator(N, c, Sims, batches,seed)

% fprintf('\n')
c = coefs(13:24);
% fprintf('Coefs\n')
% fprintf('======\n')
% fprintf('%.2f\n', c)
% fprintf('\n')
importanceMLSimulation(N, c, Sims, batches, seed)
crtMLSimulations(N, c, Sims, batches,seed)
% crbMLSimulator(N, c, Sims, batches,seed)
% arkMLSimulator(N, c, Sims, batches, seed)
% askMLSimulator(N, c, Sims, batches,seed)

% fprintf('\n')
% c = coefs(25:40);
% fprintf('Coefs\n')
% fprintf('======\n')
% fprintf('%.2f\n', c)
% fprintf('\n')
% importanceMLSimulation(N, c, Sims, batches, seed)
% crtMLSimulations(N, c, Sims, batches,seed)
% crbMLSimulator(N, c, Sims, batches,seed)
% arkMLSimulator(N, c, Sims, batches, seed)
% askMLSimulator(N, c, Sims, batches,seed)




