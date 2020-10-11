


clear;clc;

% hist(shiftedExponentialDist(1, -3,1000), 50)
% hist(shiftedExponentialDist(1, 3,1000), 50)
% hist(shiftedExponentialDist(4, -3,1000), 50)
% hist(shiftedExponentialDist(10, 3,1000), 50)

N = 10000;
z=NormalTruncatedPositive(-200, 10, N);
if sum(z<0) == 0
    disp('Test PASSED')
else
    disp('Test FAILED')
end
% figure
% histogram(z, 50)

N = 10000;
z=NormalTruncatedPositive(-200, 5, N);
if sum(z<0) == 0
    disp('Test PASSED')
else
    disp('Test FAILED')
end
% figure
% histogram(z, 50)


N = 10000;
z=NormalTruncatedPositive(-200, 1, N);
if sum(z<0) == 0
    disp('Test PASSED')
else
    disp('Test FAILED')
end
% figure
% histogram(z, 50)

N = 10000;
z=NormalTruncatedPositive(-200, .1, N);
if sum(z<0) == 0
    disp('Test PASSED')
else
    disp('Test FAILED')
end
% figure 
% histogram(z, 50)

J=4;
a= zeros(J,1);
mu = -100.*ones(J,1);
Sigma= createSigma(.5,J);
Samples = GibbsTMVN_Positive(mu,Sigma,N,1);
if sum(sum(Samples < 0)) == 0
    disp('Test PASSED')
else
    disp('Test FAILED')
end
% histogram(Samples(4,:), 50)


mu = 100.*ones(J,1);
Sigma= createSigma(.5,J);
NegativeSamples = GibbsTMVN_Negative(mu,Sigma, 10000,100);
if sum(sum(NegativeSamples) > 0) == 0
    disp('Test PASSED')
else
    disp('Test FAILED')
end
% figure
% histogram(NegativeSamples(4,:), 50)
Constraints = [1,-1];
mu = [0,0];
Sigma = eye(2);
N = 10000;
bn = 100;
out = GibbsTMVN(Constraints, mu, Sigma, N, bn);
figure
histogram(out(1,:),50)
figure
histogram(out(2,:),50)