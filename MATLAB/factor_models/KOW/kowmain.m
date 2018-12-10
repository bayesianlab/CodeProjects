%% Generated from kowGenData()
clear;
clc;
% [y, surx] = kowGenData();

% load('kowy.mat')
% load('surx.mat')
% load('kowy2.mat')
% load('kowx2.mat')
% y = kowy2;
% surx = kowx2;
% clear kowy2
% clear kowx2
load('kow.mat')
K = size(kowy,1);
rng(1)
r0 = 10.*ones(K,1);
v0 = 5;
b0 = 1;
B0 = 1;


[f, f2, b, v] = kowdynfactorgibbs(kowy, kowx,  v0, r0,  20, 1);

% g=normrnd(0,1,68,3,20);

% J=10;
% nFactors = size(g,1);
% for n = 1:nFactors
%     gammastar = mean(g(n,:,:),3);
%     
% end
% 
% for j = 1:J
% 
% end
