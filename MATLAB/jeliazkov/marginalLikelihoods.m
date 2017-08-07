clear; clc;
rng(10)
N = 100;
Sims = 300;
batches = 10;
seed = 101;
sampSize = 220;
sampBurn = 20;
redRunSize = 22;
redRunBurn = 2;
coefs = unifrnd(0,1,40,1);
c=coefs(1:4);
fprintf('Coefs\n')
fprintf('======\n')
fprintf('%.2f\n', c)
% importanceMLSimulation(N, c, sampSize, sampBurn, Sims,batches, seed)
% crtMLSimulations(N, c, sampSize, sampBurn, Sims, batches,seed)
% crbMLSimulator(N, c, sampSize, sampBurn, redRunSize, redRunBurn, Sims,...
%     batches,seed)
% arkMLSimulator(N, c, Sims, batches, seed)
% askMLSimulator(N, c, sampSize, sampBurn, Sims, batches,seed)


% fprintf('\n')
c = coefs(5:12);
% fprintf('Coefs\n')
% fprintf('======\n')
% fprintf('%.2f\n', c)
% fprintf('\n')
importanceMLSimulation(N, c, sampSize, sampBurn, Sims,batches, seed)
crtMLSimulations(N, c, sampSize, sampBurn, Sims, batches,seed)
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




