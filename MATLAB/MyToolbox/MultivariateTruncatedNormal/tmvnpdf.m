function [pval] = tmvnpdf(x, mu, Sigma, Constraints)
if ~isrow(x)
    error('x must be row')
end
if ~isrow(mu)
    error('mu must be row')
end
J = size(Sigma,1);
Precision=Sigma\eye(J);
Pjj=diag(Precision).^(-1);
selectMat = logical(ones(J)-eye(J));
Pjnotj = zeros(J,J-1);

for j = 1:J
    Pjnotj(j,:) = Precision(j, selectMat(j,:));
end
pval = zeros(J,1);
% Conditional 
for j = 1:J-1

    condmean = mu(j) - Pjj(j)*(Pjnotj(j,:)*( x(selectMat(j,:)) - mu(selectMat(j,:)))');
    s = sqrt(Pjj(j));
    z = (x(j) - condmean)/s ;
    alpha = 1-normcdf((-Constraints(j)*condmean)/s);

    if Constraints(j) == 1 || Constraints(j) == -1
        pval(j) = logmvnpdf(z, 0, 1) - log( .5*alpha );
    elseif Constraints(j) == 0
        z = (x(j) - condmean)/s ;
        pval(j)= logmvnpdf(z, 0, 1);
    else
        error('Constraint must be 0, 1 or -1');
    end
end
% Marginal 
z = (x(J) - mu(J))/sqrt(Sigma(j,j));
alpha = 1-normcdf((-Constraints(J)*condmean)/s);

if Constraints(j) == 1 || Constraints(j) == -1
    pval(j) = logmvnpdf(z, 0, 1) - log( .5*alpha );
elseif Constraints(j) == 0
    z = (x(j) - condmean)/s ;
    pval(j)= logmvnpdf(z, 0, 1);
else
    error('Constraint must be 0, 1 or -1');
end
pval = sum(pval);
end
