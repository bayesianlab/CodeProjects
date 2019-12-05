%% process kose output
clear;clc;
load('BigKowResults/Result_kowz_kose_02_Dec_2019_22_20_27.mat')
[r,c,d]=size(storeMean);
reshapedmu = reshape(permute(storeMean,[2,1,3]), r*c,d);
mean_beta = mean(reshapedmu,2);
factors=mean(storeFt,3);
% plot(factors(5,:))
% CalcVarDecomp(InfoCell, surForm(Xt,K), mean_beta, mean(storeLoadings,3), factors)
mut = reshape(surForm(Xt,K)*mean_beta,K,T);
centered=yt-mut;
om=mean(storeLoadings,3);

% boxplot(CalcIneffFactors(reshapedmu(1:4:r*c,:), 500))
