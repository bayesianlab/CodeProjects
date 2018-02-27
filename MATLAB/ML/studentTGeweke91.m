function [t] = studentTGeweke91(a,b,mu,Sigma,nu,N,burnin)
[J,~] = size(Sigma);
if isrow(mu) 
    mu = mu';
end
precision = inv(Sigma);
Hxx = diag(precision);
HxxInv = Hxx.^(-1);
sii = sqrt(HxxInv);
I = eye(J);
Hxy = zeros(J,J-1);
for j = 1:J
    notj = I([1:j-1, j+1:J], :);
    Hxy(j,:) = notj * precision(j, :)';
end
w= chi2rnd(nu,N,1);
rootw = sqrt(w*nu^(-1));
t = zeros(N, J);
alpha = a - mu;
beta = b - mu;
updateVec = zeros(J,1);
for i = 1:N
    alphaw = alpha.*rootw(i);
    betaw = beta.*rootw(i);
    for j = 1:J
        notj = I([1:j-1, j+1:J], :);
        xnot = notj*updateVec;
        innerP = HxxInv(j)*Hxy(j,:)*xnot;
        epsilon = truncNormalRand((alphaw(j) -innerP)/sii(j),...
            (betaw(j)-innerP)/sii(j), 0,1);
        updateVec(j) = innerP + sii(j)*epsilon; 
    end
    t(i,:) = updateVec;
end 
t = (t.* (rootw.^-1)) + mu';
t = t(burnin:N,:);
end


