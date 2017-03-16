clear
clc
rng(101, 'twister');
% Probit metropolis hastings
beta1 = 2
beta2 = 2
N = 1000;
x1 = normrnd(0,10, N,1);
x2 = normrnd(0,10,N,1);
eps = normrnd(0,1,N,1);

y = x1*beta1 + x2*beta2 + eps;
sigmay = std(y)
muy = mean(y)
y = (y-muy) ./ sigmay;
yi = normcdf(y);
y = binornd(1, normcdf(y));
x = [x1, x2];
params = [0.0;0.0];
dloglike = probitLL(y,x, params)
hess = probitJ(y,x,[.07;.07])


dProbit = @(b)probitLL(y,x,b)
hProbit = @(b)probitJ(y,x,b)
mles = optimizeNewton([0;0], dProbit, hProbit, 1e-3, 10, 1)
sum(y.*log(normcdf(x*mles)) + (1-y) .* log(1-normcdf(x*mles))) 
sum(y.*log(normcdf(x*[-.04;.09])) + (1-y) .* log(1-normcdf(x*[-0.04;0.09])))


rescaled = mles*sigmay
negInvHessian = -inv(probitJ(y,x,mles));
tuner = 3;
df = 5;

% Sim = 10000;
% burn = floor(Sim * .20)
% Psi = tuner*negInvHessian;
% posterior = zeros(Sim, 2);
% disp('MH')
% u = unifrnd(0,1,Sim,1);
% for i = 1:Sim
%     proposal = mvtrnd(Psi, df, 1);
%     canidate = posterior(i,:);
%     prP = mvnpdf(proposal', [0;0], eye(2))';
%     prC = mvnpdf(canidate', [0;0], eye(2))';
%     num =  probitL(y,x,proposal') + log(prP * mvtpdf(canidate, Psi, df));
%     den = probitL(y,x,canidate') +  log(prC * mvtpdf(proposal, Psi, df));                                
%     a = min(1,exp(num - den));
%     ui = u(i);
%     if ui < a
%         posterior(i+1,:) = proposal;
%     else
%         posterior(i+1,:) = canidate;
%     end
% 
% 
% end
% hist(posterior(burn:Sim,1), 10)
% post1 = mean(posterior(burn:Sim,1))
% post2 = mean(posterior(1001:Sim,2))
% 
% save '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/post1' ...
%     post1 
% save '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/post2' ...
%     post2 
% 
% save '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x1' ...
%     x1 
% save '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/x2' ...
%     x2
% save '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/y' ...
%     y
% save '/Users/dillonflannery-valadez/Google Drive/CodeProjects/MATLAB/jeliazkov/yi' ...
%     yi
% 








