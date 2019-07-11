function [yt, Xt, Ft, Beta] = kowSimDataForTest(K,T ,mu, beta, G, gamma)


NXcols = (K+1)*K;
Xt = zeros(K*T, NXcols);

% Parameter inits
Mu = mu.* ones(K,1);
Beta = ones(K,K).*beta;
Beta = [Mu,Beta]';
Si = kowStatePrecision(gamma, 1, T);
S = Si\eye(length(gamma)*T);

Ft = mvnrnd(zeros(1,T), S);
Gt = ones(K,1).*G;
X = normrnd(0,1,[T*K,K+1]);
X(:,1) = ones(T*K,1);
fillmat = kron(eye(K), ones(1,K+1));
fillx = 1:K;
for i = 1:T
    fx = fillx + (i-1)*K;
    Xt(fx, :) = fillmat.*repmat(X(fx,:), 1,K);
end
% Take out an obs for VAR(1) 
mut = reshape(Xt*Beta(:),K,T) + Gt*Ft;
yt = mut + normrnd(0,1,K,T);

end

