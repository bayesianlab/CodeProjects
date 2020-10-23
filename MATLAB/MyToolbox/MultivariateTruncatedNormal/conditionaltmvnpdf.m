function [pval] = conditionaltmvnpdf(x, mu, Sigma, Constraints)
J = size(Sigma,1);
Precision=Sigma\eye(J);
Pjj=diag(Precision).^(-1);
selectMat = logical(ones(J)-eye(J));
Pjnotj = zeros(J,J-1);

for j = 1:J
    Pjnotj(j,:) = Precision(j, selectMat(j,:));
end
pval = zeros(1,J);
for j = 1:J
    condmean = mu(j) - Pjj(j)*Pjnotj(j,:)*( x(selectMat(j,:)) - mu(selectMat(j,:)));
    s = sqrt(Pjj(j));
    z = (x(j) - condmean)/s ;
    
    if Constraints(j) == 1 || Constraints(j) == -1
        pval(j) = logmvnpdf(z, 0, 1) - log( .5*s );
    elseif Constraints(j) == 0
        z = (x(j) - condmean)/s ;
        pval(j)= logmvnpdf(z, 0, 1);
    else
        error('Constraint must be 0, 1 or -1');
    end
end
pval = sum(pval);
end

