function [yt, Xt, Factor] =...
    kowSimDataForTest(K,T ,mu, beta, G, gamma)


yt = zeros(K,T);
Factor = zeros(1, T);
NXcols = (K+1)*K;
Xt = zeros(K*T, NXcols);

% Parameter inits
ones(K,1)
Mu = mu.* ones(K,1);
Beta = ones(K,K).*beta;
Gt = ones(K,1).*G;
% Init factor
variance = 1/(1-(gamma(1)^2));
Factor(:,1) = normrnd(0,variance, 1,1);
yt(:,1) = normrnd(0,1,K,1);
for t= 2:T
   yt(:,t) = [Mu,Beta]*[1;yt(:,t-1)] + Gt*Factor(:,t)  + normrnd(0,1,K,1);
   Factor(:,t) = gamma.*Factor(:,t-1) + normrnd(0, 1,1,1);
end
% Create Xt matrix for vectorized yt
fillx = 1:K;
for i = 1:T
    fx = fillx + (i-1)*K;
    Xt(fx, :) = kron(eye(K),[1,yt(:,i)']);
end
% Take out an obs for VAR(1) 

Xt = Xt(1:(T-1)*K,:);
Xt = sparse(Xt);
yt = yt(:, 2:T);

end

