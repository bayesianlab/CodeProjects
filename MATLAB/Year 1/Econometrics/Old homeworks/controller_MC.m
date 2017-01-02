
% Abalone data from UCI Machine Learning Repository. 
% Rings are an approximation for age. Construct
% a new y variable through the function dgp (Data Generating
% Process) and do monte carlo sims to see distribution of 
% beta_hats with different error terms.

clear;
clc;
import_abalonedata;
shellWght = SHELLWEIGHT;
nSims = 100;
beta = [1;4];
plotMCSims(shellWght, nSims)



