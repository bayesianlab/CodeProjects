
clear;
clc;
% rng(77, 'twister');
smpsize = 100;
beta1=1;
beta2=.5;
s = .2;
x1 = randn(smpsize,1);
X = [ones(smpsize,1), x1];
y = beta1 + beta2*x1 + sqrt(s)*randn(smpsize,1);

B0 = 4*eye(2);
B0inv = inv(B0);
a0 = 6;
d0 = 2.5;
beta0 = zeros(2,1);
sigmaInit = 1;
mle = inv(X'*X)*X'*y
re = y- X*[beta1;beta2];
sshat = re'*re/smpsize
[b,s] = lrGibbs(10, 2, y, X, beta0, B0, sigmaInit, a0, d0);

betamean = mean(b);
sigmamean = mean(s);


trueMarginalLikelihood = analyticalMarginalLikelihood(y, X, [0;0], B0, a0, d0)
chib = chibsMethod(b, s, X,y, B0, beta0, a0, d0)



% %---------------------------------
% %calculate the ML using Gelfand-Dey method
% %---------------------------------
mean_vec = [betamean sigmamean]';
k= 2;
add_on = zeros(k+1,k+1);

for i = 1:length(s)
    temp_term = ([b(i,:) s(i,1)]' - mean_vec)*([b(i,:) s(i,1)]' - mean_vec)';
    add_on = add_on + temp_term;
end
cov_mat = (1/length(s))*add_on
det_cov = det(cov_mat);
inv_cov = inv(cov_mat)
np = k+1;
% %loop and calculate the "weight" for each post-convergence draw;
weight_GD = zeros(length(s),1);
for i = 1:length(s)
    parms = [b(i,:) s(i,1)]';
    critical = (parms - mean_vec)'*inv_cov*(parms-mean_vec);
    if critical < 11.34 %99th percentile of chisquare (3) density. 
        prior_b = ((2*pi*s(i,1))^(-k/2))*((det(B0))^(-1/2))*exp(-(1/(2*s(i,1)))*b(i,:)*B0inv*b(i,:)');
        prior_s = inv(gamma(a0*.5)) * ((d0*.5)^(a0*.5)) * (s(i,1)^(-( (a0*.5) +1))) * exp(-(d0*.5)/s(i,1));
        likefun = (2*pi*s(i,1))^(-smpsize/2)*exp(-(1/(2*s(i,1)))*(y-X*b(i,:)')'*(y-X*b(i,:)'));
        f_part = (1/.99)*((2*pi)^(-np/2))*(det_cov^(-1/2))*exp(-.5*(parms - mean_vec)'*inv_cov*(parms-mean_vec));
        disp([f_part, prior_b, prior_s, likefun ])
        weight_GD(i,1) = f_part/(prior_b*prior_s*likefun);
    end
end

weights_use = nonzeros(weight_GD); %discard those draws falling outside the region of truncation
size(weights_use)
disp('Log Marginal Likelihood via Gelfand-Dey');
GD_marglike = -log(mean(weights_use))