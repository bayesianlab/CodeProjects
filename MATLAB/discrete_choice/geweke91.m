function [ X ] = geweke91(a,b,mu,Sigma,sims,burn,init )
J = size(Sigma,1);
alpha = a - mu;
beta = b - mu;
H = Sigma\eye(J);
hii = diag(H);
roothii = sqrt(1./hii);
preprecision = zeros(J,J-1);
notj = notJindxs(J);
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
        init(j) = condmean + (roothii(j)*ep(j));
    end
    z(:,i) = init
end

X = mu + z(:, burn+1:sims);
% if sum(sum(~isfinite(X)))> 0
%     save('erroroutput.mat')
%     X = 'error';
%     
% end
