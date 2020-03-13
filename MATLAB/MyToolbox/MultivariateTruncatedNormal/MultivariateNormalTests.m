clear;clc;
J=4;
a= zeros(J,1);

mu = -100.*ones(J,1);
Sigma= createSigma(.5,J);
Samples = GibbsTMVN_Positive(mu,Sigma,10000,10);
% hist(Samples(4,:), 50)


mu = 100.*ones(J,1);
Sigma= createSigma(.5,J);
NegativeSamples = GibbsTMVN_Negative(mu,Sigma, 10000,100)
hist(NegativeSamples(4,:), 50)