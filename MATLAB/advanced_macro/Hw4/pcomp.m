clear 
clc
tenyearTs = load('tenyearMat.mat');
tyts = tenyearTs.tenyearMat;

relevantRange = tyts(1:11334,:);
[r,c] = find(isnan(relevantRange));
relevantRange(2217, :) = [];



cmeans = mean(relevantRange);
cstds = std(relevantRange);
normRange = (relevantRange-cmeans)./cstds;
[f, load, ev, err] = extract(normRange, 3);

load.^2
mean(load.^2, 2)
cumsum(mean(load.^2,2))






