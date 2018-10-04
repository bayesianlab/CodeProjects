function [ X ] = geweke91(a,b,mu,Sigma,sims,burn,init )
J = size(Sigma,1);
alpha = a - mu;
beta = b - mu;
H = Sigma\eye(J);
hii = diag(H);
roothii = sqrt(hii);
preprecision = zeros(J,J-1);
notj = notJindxs(J);
curz = zeros(J,1);
ep = zeros(J,1);
z = zeros(J,sims);
for j = 1:J
    preprecision(j,:) = -(1/hii(j)).*H(j, notj(j,:));
end
for i = 1:sims
    for j = 1:J
        xnot = init(notj(j,:));
        condmean = preprecision(j,:)*xnot;
        lowerb = (alpha(j) - condmean)/roothii(j);
        upperb = (beta(j) - condmean)/roothii(j);
        ep(j) = tnormrnd(lowerb,upperb,0,1);
        curz(j) = condmean + (roothii(j)*ep(j));
        init = curz;
    end
    z(:,i) = curz;
end
X = mu + z(:, burn+1:sims);