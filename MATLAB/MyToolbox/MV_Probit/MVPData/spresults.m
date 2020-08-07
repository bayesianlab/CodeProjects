clear;clc;

load('results_sp4factor.mat')

storeBeta = Output{1};
storeFt = Output{2} ;
storeSt = Output{3};
storeOm = Output{4};
ml = Output{5};
overview = Output{6} ;

mub = mean(storeBeta,2);
Fhat = mean(storeFt,3);

% hold on 
% plot(Fhat(1,:))
% plot(Fhat(2,:))
% plot(Fhat(3,:))

omhat = mean(storeOm,3);
sthat = mean(storeSt,3);

yhat = mub + omhat*Fhat;
plot(yhat(1,:))
sum(yhat > 0,2)
sum(yt > 0,2)


