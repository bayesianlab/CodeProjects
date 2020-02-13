%% process kose output
clear;
clc;
load('ResultsUsedInPaper/Kose_Observables_Feb10th.mat')
[r,c,d]=size(storeMean);
reshapedmu = reshape(permute(storeMean,[2,1,3]), r*c,d);
constants = 1:4:r*c;
beta1 = 2:4:r*c;
beta2 = 3:4:r*c;
beta3 = 4:4:r*c;
[method1c, m1c]=CalcIneffFactors(reshapedmu(constants,:), 7000);
[method1b1, m1b1] = CalcIneffFactors(reshapedmu(beta1,:), 7000);
[method1b2, m1b2] = CalcIneffFactors(reshapedmu(beta2,:), 7000);
[method1b3, m1b3] = CalcIneffFactors(reshapedmu(beta3,:), 7000);
avg_method1 = (method1c + method1b1 + method1b2 + method1b3)/4;

m1 = [mean(m1c); mean(m1b1);mean(m1b2); mean(m1b3)];

worldLoading = squeeze(storeLoadings(2:180,1,:));
regionLoading = squeeze(storeLoadings(:,2,:));
rs = InfoCell{2};
rs=rs(:,1);
rs = setdiff(1:180, rs);
regionLoading = regionLoading( rs,:);
wl1 = CalcIneffFactors(worldLoading,500);
rl1 = CalcIneffFactors(regionLoading,500);
cs=InfoCell{3};
cs=cs(:,1);
cs=setdiff(1:180,cs);
countryLoading=squeeze(storeLoadings(:,2,:));
countryLoading=countryLoading(cs,:);
cl1 = CalcIneffFactors(countryLoading,500);

st = squeeze(storeStateArTerms);
st1 = CalcIneffFactors(st,500);

mean_beta = mean(reshapedmu,2);
om=mean(storeLoadings,3);
mut = reshape(surForm(Xt,K)*mean_beta,K,T);
factors=mean(storeFt,3);
CalcVarDecomp(InfoCell, surForm(Xt,K), mean_beta, mean(storeLoadings,3), factors)
load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/ResultsUsedInPaper/NewMethod_Feb4th.mat')
[r,c,d]=size(storeVAR);
constants = 1:4:r*c;
beta1 = 2:4:r*c;
beta2 = 3:4:r*c;
beta3 = 4:4:r*c;
[r,c,d] = size(storeVAR);
vars = reshape(storeVAR,r*c,d);
[method2c, m2c] =CalcIneffFactors(vars(constants,:), 500);
[method2b1, m2b1] = CalcIneffFactors(vars(beta1,:), 500);
[method2b2, m2b2]  = CalcIneffFactors(vars(beta2,:), 500);
[method2b3,m2b3] = CalcIneffFactors(vars(beta3,:), 500);
avg_method2 = (method2c + method2b1 + method2b2 + method2b3)/4;

m2 = [mean(m2c);
mean(m2b1);
mean(m2b3);
mean(m2b3)];
beta_ineff = [m1,m2];

figure
boxplot([avg_method1, avg_method2], 'symbol', '', 'Labels', {'Full Conditionals (K.O.W.)', 'New Method'})
ylim([-40,1000])
saveas(gcf, '~/GoogleDrive/statespace/boxplot_beta.jpeg')

worldLoading = squeeze(storeOM(2:180,1,:));
wl2 = CalcIneffFactors(worldLoading,500);
regionLoading = squeeze(storeOM(:,2,:));
regionLoading = regionLoading( rs,:);
rl2 = CalcIneffFactors(regionLoading,500);
countryLoading=squeeze(storeOM(:,1:end));
countryLoading=countryLoading(cs,:);
cl2 = CalcIneffFactors(countryLoading,500);
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
ylim([-20,300])
xtickangle(25)
saveas(gcf, '~/GoogleDrive/statespace/boxplot_loadings.jpeg')
st = squeeze(storeStateTransitions);
st2 = CalcIneffFactors(st,500);
figure
boxplot([st1,st2], 'symbol','', 'Labels', {'Full Conditionals (K.O.W.)', 'New Method'})
ylim([-1,25])
saveas(gcf, '~/GoogleDrive/statespace/boxplot_state_transitions.jpeg')