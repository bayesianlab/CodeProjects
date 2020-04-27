function [storeb, stores2] = SimpleGibbsLS(y,X, b0, B0, nu0, d0, Sims,burnin)
%% For scalar y, K predictors, T observations
[T, K] = size(X);
B0i = B0\eye(K);
B0ib0 = B0i*b0;
nu1 = T+nu0;

XpX = X'*X;
Xpy = X'*y;

Runs = Sims - burnin;
storeb = zeros(K,Runs);
stores2 = zeros(1,Runs);
s2 = 1;
for nn =1:Sims
    
    B1 = ( ((XpX)/s2 ) + B0i);
    B1lowerinv = chol(B1,'lower')\eye(K);    
    b1= (B1lowerinv'*B1lowerinv) * (( Xpy/s2 ) + B0ib0);    
    b = b1 + B1lowerinv'*normrnd(0,1,K,1);
    e = y-(X*b);
    
    del1 = d0 + e'*e;
    s2 = 1/gamrnd(.5*nu1, 1/(.5*del1));
    
    if nn > burnin
        storeindex = nn-burnin;
        storeb(:,storeindex) = b;
        stores2(storeindex) = s2;
    end
    end
end

