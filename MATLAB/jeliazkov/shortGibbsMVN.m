function [x] = shortGibbsMVN(x, mu, Sigma, Constraints, start)
J = size(Sigma,1);
Precision=Sigma\eye(J);
Pjj=diag(Precision).^(-1);
selectMat = logical(ones(J)-eye(J));
Pjnotj = zeros(J,J-1);

for j = 1:J
    Pjnotj(j,:) = Precision(j, selectMat(j,:));
end
for j = start:J
    if Constraints(j) == 1
        condmean = mu(j) -Pjj(j)*Pjnotj(j,:)*( x(selectMat(j,:)) - mu(selectMat(j,:)));
        x(j) = NormalTruncatedPositive(condmean,Pjj(j), 1);
    elseif Constraints(j) == -1
        condmean = mu(j) - Pjj(j)*Pjnotj(j,:)*( x(selectMat(j,:)) - mu(selectMat(j,:)));
        x(j) = -NormalTruncatedPositive(-condmean,Pjj(j), 1);
    elseif Constraints(j) == 0 
      condmean = mu(j) - Pjj(j)*Pjnotj(j,:)*( x(selectMat(j,:)) - mu(selectMat(j,:)));
      x(j) = condmean + sqrt(Pjj(j))*normrnd(0,1);
    else
        error('Constraint must be 0, 1 or -1');
    end
end
end

