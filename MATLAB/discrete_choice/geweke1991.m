function [ z, p ] = geweke1991 (a,b,mu,Sigma,sims,burn,init)
J = size(Sigma,1);
H = Sigma\eye(J);
hii = diag(H);
roothii = sqrt(1./hii);
preprecision = zeros(J,J-1);
notj = notJindxs(J);
z = zeros(J,sims);
p=0;
H
for j = 1:J
    H(j, notj(j,:))
    preprecision(j,:) = (1/hii(j)).*H(j, notj(j,:));
end
for i = 1:sims
    for j = 1:J
        xnot = init(notj(j,:))
        munot = mu(notj(j,:))
        (xnot-munot)
        preprecision(j,:)
        cmean = mu(j) - preprecision(j,:)*(xnot-munot)

        init(j) = tnormrnd(a(j),b(j),cmean,roothii(j));
    end
    z(:,i) = init;
end
% if sum(sum(~isfinite(z))) > 0
%     save('gewekeerrormat.mat')
%     p = 1
% end
end
