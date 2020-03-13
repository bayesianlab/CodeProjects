function [gibbsout] = GibbsTMVN_Negative(mu, Sigma,N, bn)
% Assumes upperconstraint of 0
J = size(Sigma,1);
Precision=Sigma\eye(J);
Pjj=diag(Precision).^(-1);
selectMat = logical(ones(J)-eye(J));
Pjnotj = zeros(J,J-1);

for j = 1:J
    Pjnotj(j,:) = Precision(j, selectMat(j,:));
end
gibbsout=zeros(J,N);
x = mu;
for n = 1:N
    for j = 1:J
        condmean = mu(j) - Pjj(j)*Pjnotj(j,:)*( x(selectMat(j,:)) - mu(selectMat(j,:)));
        x(j) = -NormalTruncatedPositive(-condmean,Pjj(j), 1);
    end
    gibbsout(:,n) = x;
end
if bn ~=0
    gibbsout=gibbsout(:,bn:end);
end
end

