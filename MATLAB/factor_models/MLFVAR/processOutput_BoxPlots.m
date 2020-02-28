%% process kose output
clear;
clc;
MAXN = 1000;
load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/ResultsUsedInPaper/Result_kow_standardized_Kose_Observables_26_Feb_2020_21_43_16.mat')
[r,c,d]=size(storeMean);
reshapedmu = reshape(permute(storeMean,[2,1,3]), r*c,d);
constants = 1:4:r*c;
beta1 = 2:4:r*c;
beta2 = 3:4:r*c;
beta3 = 4:4:r*c;
[method1c, m1c]=CalcIneffFactors(reshapedmu(constants,:), MAXN);
[method1b1, m1b1] = CalcIneffFactors(reshapedmu(beta1,:), MAXN);
[method1b2, m1b2] = CalcIneffFactors(reshapedmu(beta2,:), MAXN);
[method1b3, m1b3] = CalcIneffFactors(reshapedmu(beta3,:), MAXN);
betas1 = [method1c,method1b1,method1b2, method1b3];
avg_method1 = mean(betas1,2)

worldLoading = squeeze(storeLoadings(2:180,1,:));
regionLoading = squeeze(storeLoadings(:,2,:));
rs = InfoCell{2};
rs=rs(:,1);
rs = setdiff(1:180, rs);
regionLoading = regionLoading( rs,:);
wl1 = CalcIneffFactors(worldLoading,MAXN);
rl1 = CalcIneffFactors(regionLoading,MAXN);
cs=InfoCell{3};
cs=cs(:,1);
cs=setdiff(1:180,cs);
countryLoading=squeeze(storeLoadings(:,2,:));
countryLoading=countryLoading(cs,:);
cl1 = CalcIneffFactors(countryLoading,MAXN);

st = squeeze(storeStateArTerms);
st1 = CalcIneffFactors(st,MAXN);

mean_beta = mean(reshapedmu,2);
om=mean(storeLoadings,3);
mut = reshape(surForm(Xt,K)*mean_beta,K,T);
factors=mean(storeFt,3);

[method1var, m1v]=CalcIneffFactors(storeObsV,MAXN);
[method1fvar,m1fv] = CalcIneffFactors(storeFactorVariance, MAXN);

load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/ResultsUsedInPaper/NewMethod_Feb23rd.mat')
[r,c,d]=size(storeVAR);
constants = 1:4:r*c;
beta1 = 2:4:r*c;
beta2 = 3:4:r*c;
beta3 = 4:4:r*c;
[r,c,d] = size(storeVAR);
vars = reshape(storeVAR,r*c,d);
[method2c, m2c] =CalcIneffFactors(vars(constants,:), MAXN);
[method2b1, m2b1] = CalcIneffFactors(vars(beta1,:), MAXN);
[method2b2, m2b2]  = CalcIneffFactors(vars(beta2,:), MAXN);
[method2b3,m2b3] = CalcIneffFactors(vars(beta3,:), MAXN);
betas2 = [method2c,method2b1, method2b2, method2b3];
avg_method2 = mean(betas2,2);


figure
boxplot([avg_method1, avg_method2], 'symbol', '', 'Labels', {'Full Conditionals (K.O.W.)', 'New Method'})
ylim([-50,320])
saveas(gcf, '~/GoogleDrive/statespace/boxplot_beta.jpeg')

worldLoading = squeeze(storeOM(2:180,1,:));
wl2 = CalcIneffFactors(worldLoading,MAXN);
regionLoading = squeeze(storeOM(:,2,:));
regionLoading = regionLoading( rs,:);
rl2 = CalcIneffFactors(regionLoading,MAXN);
countryLoading=squeeze(storeOM(:,1:end));
countryLoading=countryLoading(cs,:);
cl2 = CalcIneffFactors(countryLoading,MAXN);
bpdata = [wl1; rl1; cl1; wl2; rl2; cl2];
g1 = repmat({'Full Conditionals (K.O.W.):World'}, 179,1);
g2 = repmat({'Full Conditionals (K.O.W.):Region'}, 173,1);
g3 = repmat({'Full Conditionals (K.O.W.):Country'}, 120,1);
g4 = repmat({'New Method:World'}, 179,1);
g5 = repmat({'New Method:Region'}, 173,1);
g6 = repmat({'New Method:Country'}, 120,1);
g=[g1;g2;g3;g4;g5;g6];

figure
boxplot(bpdata, g,'symbol', '')
ylim([0,30])
xtickangle(25)
saveas(gcf, '~/GoogleDrive/statespace/boxplot_loadings.jpeg')
st = squeeze(storeStateTransitions);
st2 = CalcIneffFactors(st,MAXN);

figure
boxplot([st1,st2], 'symbol','', 'Labels', {'Full Conditionals (K.O.W.)', 'New Method'})
ylim([0,110])
saveas(gcf, '~/GoogleDrive/statespace/boxplot_state_transitions.jpeg')

figure
[method2var, m2v]=CalcIneffFactors(1./storeObsPrecision,MAXN);
boxplot([method1var, method2var], 'symbol','', 'Labels', {'Full Conditionals (K.O.W.)', 'New Method'})
ylim([0,7])
saveas(gcf, '~/GoogleDrive/statespace/boxplot_omvar.jpeg')

figure
[method2fvar,m2fv] = CalcIneffFactors(storeFactorVar,MAXN);
boxplot([method1fvar, method2fvar], 'symbol','', 'Labels', {'Full Conditionals (K.O.W.)', 'New Method'})
ylim([0,11])
saveas(gcf, '~/GoogleDrive/statespace/boxplot_fvar.jpeg')

round([mean([wl1, wl2]);
mean([rl1,rl2]);
mean([cl1,cl2]);
mean([avg_method1, avg_method2]);
mean([st1,st2]);
mean([method1var,method2var]);
mean([method1fvar,method2fvar])],0)
