clear 
clc

imp_data;
X = [constant, x_1, x_2];

sims = 1000;
burnin = (sims/10)+1;
us = unifrnd(0,1, sims,1);

[coefs, ses, hessian ] = logit_NR_Method([0,0,0]', X, y, .0005);
estimates = coefs
invHessian = inv(-hessian)

betas = vertcat(coefs', zeros(sims,3));
[r,c] = size(betas);

nu = 5;
accept =  0;



for i = 1:sims
    
   betas(i+1, :) = coefs' + mvtrnd(invHessian, nu, 1);
   
   proposed_beta = betas(i+1, :);
   last_beta = betas(i, :);
   
   like_n = logit_likelihood(proposed_beta', X, y);
   prior_n = prior( proposed_beta -coefs' );
   proposal_n =  mvtpdf( last_beta - coefs', invHessian, nu);
   
   like_d = logit_likelihood(last_beta', X, y);
   prior_d = prior(last_beta - coefs');
   proposal_d =  mvtpdf( proposed_beta - coefs', invHessian, nu);
   
   ratio = (like_n * prior_n * proposal_n) /...
       ( like_d * prior_d * proposal_d);
   
   alpha = min( 1, ratio ) ;
   
   if us(i) < alpha
       accept = accept + 1;
       betas(i+1, :) = proposed_beta ;
   else
       betas(i+1, :) = last_beta;
   end

    
end

acceptance = accept/sims
tic
[meffs, stdevs ] = avg_mar_effect(betas', X)
toc

beta0 = betas(burnin:sims, 1);
beta1 = betas(burnin:sims, 2);
beta2 = betas(burnin:sims, 3);
subplot(3,1,1)
plot(beta0)
subplot(3,1,2)
plot(beta1)
subplot(3,1,3)
plot(beta2)
meanb0 = mean(beta0)
meanb1 = mean(beta1)
meanb2 = mean(beta2)