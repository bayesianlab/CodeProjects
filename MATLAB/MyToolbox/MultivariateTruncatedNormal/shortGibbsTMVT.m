function [x] = shortGibbsTMVT(x, mu, Sigma, df, Constraints, start)
%% Constraints vector is 1 if sampling from positive region
%  -1 if sampling from negative region
J = size(Sigma,1);
if J == 1
    error('Must be multivariate')
end
Precision=Sigma\eye(J);
Pjj=diag(Precision).^(-1);
selectMat = logical(ones(J)-eye(J));
Pjnotj = zeros(J,J-1);

for j = 1:J
    Pjnotj(j,:) = Precision(j, selectMat(j,:));
end
W = sqrt( df/chi2rnd(df) );
for j = start:J
    demean = x(selectMat(j,:)) - mu(selectMat(j,:));
    condmean = mu(j) - Pjj(j)*Pjnotj(j,:)*demean;
    if Constraints(j) == 1
        x(j) = NormalTruncatedTPositive(condmean, Pjj(j), W, 1);
    elseif Constraints(j) == -1
        x(j) = -NormalTruncatedTPositive(-condmean,Pjj(j), W, 1);
    elseif Constraints(j) == 0
        x(j) = condmean + W.*sqrt(Pjj(j))*normrnd(0,1);
    else
        error('Constraint must be 0, 1 or -1');
    end
end
end

