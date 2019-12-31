%% process kose output
clear;clc;
load('BigKowResults/Result_kowz_kose_02_Dec_2019_22_20_27.mat')
% load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/BigKowResults/Result_kose_replication_notstandardized_30_Dec_2019_16_41_46.mat')
% [r,c,d]=size(storeMean);
% reshapedmu = reshape(permute(storeMean,[2,1,3]), r*c,d);
% constants = 1:4:r*c;
% beta1 = 2:4:r*c;
% beta2 = 3:4:r*c;
% beta3 = 4:4:r*c;
% [method1c, m1c]=CalcIneffFactors(reshapedmu(constants,:), 500);
% [method1b1, m1b1] = CalcIneffFactors(reshapedmu(beta1,:), 500);
% [method1b2, m1b2] = CalcIneffFactors(reshapedmu(beta2,:), 500);
% [method1b3, m1b3] = CalcIneffFactors(reshapedmu(beta3,:), 500);
% avg_method1 = (method1c + method1b1 + method1b2 + method1b3)/4;


% worldLoading = squeeze(storeLoadings(2:180,1,1001:end));
% regionLoading = squeeze(storeLoadings(:,2,1001:end));
% rs = InfoCell{2};
% rs=rs(:,1);
% rs = setdiff(1:180, rs);
% regionLoading = regionLoading( rs,:);
% wl1 = CalcIneffFactors(worldLoading,500);
% rl1 = CalcIneffFactors(regionLoading,500);
% cs=InfoCell{3};
% cs=cs(:,1);
% cs=setdiff(1:180,cs);
% countryLoading=squeeze(storeLoadings(:,2,1001:end));
% countryLoading=countryLoading(cs,:);
% cl1 = CalcIneffFactors(countryLoading,500);



% centered=yt-mut;
% mean_beta = mean(reshapedmu,2);
% om=mean(storeLoadings,3);
% mut = reshape(surForm(Xt,K)*mean_beta,K,T);
% factors=mean(storeFt,3);
% CalcVarDecomp(InfoCell, surForm(Xt,K), mean_beta, mean(storeLoadings,3), factors)

load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/BigKowResults/Result_kow_notcentered_22_Dec_2019_19_29_35.mat')
% Ft = mean(storeFt,3);
% [r,c,d] = size(storeVAR);
% vars = reshape(storeVAR,r*c,d);

% [mean(vars,2),reshape(mean(storeVAR,3),720,1)]
% [method2c, m2c] =CalcIneffFactors(vars(constants,:), 500);
% [method2b1, m2b1] = CalcIneffFactors(vars(beta1,:), 500);
% [method2b2, m2b2]  = CalcIneffFactors(vars(beta2,:), 500);
% [method2b3,m2b3] = CalcIneffFactors(vars(beta3,:), 500);
% avg_method2 = (method2c + method2b1 + method2b2 + method2b3)/4;
% boxplot([avg_method1, avg_method2], 'symbol', '', 'Labels', {'Method 1', 'Method 2'})
% title('\beta')
% 
worldLoading = squeeze(storeOM(2:180,1,:));
wl2 = CalcIneffFactors(worldLoading,500);
regionLoading = squeeze(storeOM(:,2,:));
regionLoading = regionLoading( rs,:);
rl2 = CalcIneffFactors(regionLoading,500);
countryLoading=squeeze(storeOM(:,1:end));
countryLoading=countryLoading(cs,:);
cl2 = CalcIneffFactors(countryLoading,500);
bpdata = [wl1; rl1; cl1; wl2; rl2; cl2];
g1 = repmat({'Method 1:World'}, 179,1);
g2 = repmat({'Method 1:Region'}, 173,1);
g3 = repmat({'Method 1:Country'}, 120,1);
g4 = repmat({'Method 2:World'}, 179,1);
g5 = repmat({'Method 2:Region'}, 173,1);
g6 = repmat({'Method 2:Country'}, 120,1);
g=[g1;g2;g3;g4;g5;g6];
boxplot(bpdata, g,'symbol', '')
ylim([0,160])
