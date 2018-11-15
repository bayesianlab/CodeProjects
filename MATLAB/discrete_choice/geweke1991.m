function [ x] = geweke1991 (a,b,mu,Sigma,sims)
J = size(Sigma,1);
H = Sigma\eye(J);
hii = diag(H);
roothii = sqrt(1./hii);
preprecision = zeros(J,J-1);
notj = notJindxs(J);
z = zeros(J,sims);
alpha = a - mu;
beta = b - mu;
for j = 1:J
    preprecision(j,:) = -(1/hii(j)).*H(j, notj(j,:));
end
init = zeros(J,1);
for i = 1:sims
    for j = 1:J
        xnot = init(notj(j,:));
        cmean = preprecision(j,:)*xnot;
        lower = (alpha(j)-cmean)/roothii(j);
        upper = (beta(j) - cmean)/roothii(j);
        init(j) = cmean + roothii(j)*tnormrnd(lower,upper,0, 1);
    end
    z(:,i) = init;
end
x = mu + z;
end
