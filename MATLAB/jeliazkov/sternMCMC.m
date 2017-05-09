function [ ml ] = sternMCMC(a,b,mu,sigma, sims, burnin)
[J,~] = size(sigma);
[~,v] = eig(sigma);
minEig = min(diag(v));
Lambda = eye(J)*minEig;
Omega = sigma-Lambda;
sample = zeros(sims,J,2);
y = zeros(1,J);
zMu = zeros(1,J);
rootMinEig = sqrt(minEig);
for i = 1:sims
   z = mvnrnd(zMu,  Omega,1);
   aj = (a - mu - z)./rootMinEig;
   bj = (b - mu - z)./rootMinEig;
   for j = 1:J
       Fa = normcdf(aj(j));
       Fb = normcdf(bj(j));
       y(j) = norminv(unifrnd(0,1,1)* (Fb-Fa) + Fa);
   end
   sample(i, :, 1) = y;
   sample(i, :, 2) = z;
end
u = mu + (rootMinEig.*sample(:,:,1))+sample(:,:,2);
u = u(burnin+1:sims,:);
[r,~] = size(u);
p =  inv(sigma);
notj = notJindxs(J);
cv = diag(p);
H11 =  p(1,1);
Hy1 = p(1, notj(1,:));
uNot1 = u(:, notj(1,:));
muNot1 = mu(notj(1,:));
muj = conditionalMeanMVN(mu(1), H11, Hy1, uNot1, muNot1)';
u1CondMeanVar = [ muj, repmat(sqrt(1/H11), r,1)];
uStar = mean(u,1);
K = sternKernel(a,b, u1CondMeanVar, uStar, u, mu, p, cv);
ml = log(mvnpdf(uStar, mu, sigma)/mean(prod(K,2)));
end

