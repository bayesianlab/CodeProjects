function [B,LR,SSR,omega,residvar,resids] = VAR(y,p,printfl)
% [B,LR,SSR,omega,residvar,resids] = VAR(y,p,printfl)
% VAR uses equation-by-equation OLS to generate coefficient
%   estimates for a VAR(p) model of the matrix of time series y.
% The n columns of y are separate time series; the T rows of y are the
%   observations for these series
% B is the ((np+1) x n) matrix of estimated coefficients for the system
% LR is the likelihood ratio statistic
% SSR is the total sum of squared residuals for the n-equation system
% omega is an (np+1) x (np+1) x n array of variance-covariance matrices,
%  one matrix for each of the n equations in the VAR
% residvar is the n x n variance-covariance matrix of the estimated residuals
% resids is the Txn matrix of residuals for the estimated system
%
% credits: written by Eric T. Swanson, 1999, updated 2000, 2001.
%

if (nargin<3); printfl=1; end ;
if (nargin<2); p = 1; end ;
[T,n] = size(y) ;

for i=0:p-1
  X(:,i*n+1:(i+1)*n) = y(p-i:T-i-1,:) ;
end
X(:,p*n+1) = ones(T-p,1) ; % constant term
y = y(p+1:T,:) ;

[B,omega,stats,resids] = ols(y,X,printfl,0) ; % eqn-by-eqn OLS
residvar = resids'*resids / (T-p-(n*p+1)) ; % unbiased in small samples

SSR = sum(sum(resids.^2)) ; % eq-by-eq OLS is GLS, so we can just take
                            %  the simple SSR

LR = -T*n/2*log(2*pi) - T/2*log(det(residvar)) - T*n/2 ; % log-likelihood
                              %  function for likelihood ratio tests

% Some alternative small-sample corrections for the LR statistic.
% These corrections matter a *lot* for typical VARs.
% The best small-sample correction is probably the LR statistic above,
%  perhaps multiplying the test (LR_u - LR_r) by a factor (T-n*p_u)/T.
% For small samples, the F-test (or equivalently, Wald test) seems to be
%  much more stable, and probably should be given more weight.
%
% When conducting hypothesis tests using these statistics, one should
%  really bootstrap the generated test statistics to calculate
%  small-sample critical values.
%
% omega = resids'*resids / (T-p) ; % biased in small samples
% LR = -(T-p)*n/2*log(2*pi) - (T-(n+1)*p)/2*log(det(omega)) - (T-p)*n/2 ; 
% LR = -(T-p)*n/2*log(2*pi) - (T-p)/2*log(det(omega)) - (T-p)*n/2 ; 
%

