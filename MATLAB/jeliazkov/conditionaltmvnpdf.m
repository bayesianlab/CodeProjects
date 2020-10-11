function [pval] = conditionaltmvnpdf(x, mu, Sigma, Constraints, condIndex)
J = size(Sigma,1);
Precision=Sigma\eye(J);
Pjj=diag(Precision).^(-1);
selectMat = logical(ones(J)-eye(J));
Pjnotj = zeros(J,J-1);

for j = 1:J
    Pjnotj(j,:) = Precision(j, selectMat(j,:));
end
condmean = mu(condIndex) - Pjj(condIndex)*Pjnotj(condIndex,:)*( x(selectMat(condIndex,:)) - mu(selectMat(condIndex,:)));
s = sqrt(Pjj(condIndex));
z = (x(condIndex) - condmean)/s ; 

if Constraints(condIndex) == 1 || Constraints(condIndex) == -1
    pval = logmvnpdf(z, 0, 1) - log( .5*s );     
elseif Constraints(condIndex) == 0 
    z = (x(condIndex) - condmean)/s ; 
    pval= logmvnpdf(z, 0, 1);
else
    error('Constraint must be 0, 1 or -1');
end
end

