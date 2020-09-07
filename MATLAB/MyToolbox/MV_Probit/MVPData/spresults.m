clear;clc;

load('results_sp2factor.mat')
rng(10342)

% hold on 
% plot(Fhat(1,:))
% plot(Fhat(2,:))

mubeta = mean(storeBeta,2);
ombar = mean(storeOm,3);
probity=import_probity();
spx = import_spx();
Xt2 = table2array( spx(:,2:end) );
yt2 = table2array( probity(:,2:end) )';

yt2 = yt2(:, 1215:end);
[K2,T2]= size(yt2);
Xt2 = Xt2(1215:end, 1:3);
Xt2 = [ones(T2,1), Xt2];
Xt2 = kron(Xt2,ones(K,1));


yts = dyn_fac_forecast(Xt2, storeBeta, storeOm, storeFt, storeSt, InfoCell);
mean(yts,3)
r1 = sum(mean(yts,3) > 0==yt2,2)./ T2

load('results_uncorrelatedprobit.mat')

storeBeta = Output{1};
mb = mean(storeBeta,2);


yts2 = probit_forecast(yt, Xt2, storeBeta);

r2 = sum(mean(yts2,3) > 0==yt2,2)./ T2

[r1, r2]
mean([r1, r2])