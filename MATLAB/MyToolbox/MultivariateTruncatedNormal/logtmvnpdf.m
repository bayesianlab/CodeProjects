function [lpdf] = logtmvnpdf(Constraints, x, mu, Sigma)
%% Constraints vector is 1 if sampling from positive region
%  -1 if sampling from negative region
J = size(Sigma,1);
Precision=Sigma\eye(J);
Pjj=diag(Precision).^(-1);
selectMat = logical(ones(J)-eye(J));
Pjnotj = zeros(J,J-1);

for j = 1:J
    Pjnotj(j,:) = Precision(j, selectMat(j,:));
end

[N,K] = size(x);
lpdf = zeros(N,1);

for n = 1:N
    % Conditional
    for j = 1:J-1
        if Constraints(j) == 1 || Constraints(j) == -1
            condmean = mu(j) - Pjj(j)*Pjnotj(j,:)*( x(selectMat(j,:)) - mu(selectMat(j,:)))';
            s = sqrt(Pjj(j));
            z = (x(j) - condmean)/s ;
            lpdf(n,1) = lpdf(n,1) + logmvnpdf(z, 0, 1) - log( .5*s );
        elseif Constraints(j) == 0
            condmean = mu(j) - Pjj(j)*Pjnotj(j,:)*( x(selectMat(j,:)) - mu(selectMat(j,:)))';
            s = sqrt(Pjj(j));
            z = (x(j) - condmean)/s ; 
            lpdf(n,1) =lpdf(n,1) + logmvnpdf(z, 0, 1);
        else
            error('Constraint must be 0, 1 or -1');
        end
    end
    % Marginal 
    if Constraints(J) == 1 || Constraints(J) == -1
        s = sqrt(Sigma(J,J));
        z = (x(J) - mu(J))/s;
        lpdf(n,1) = lpdf(n,1) + logmvnpdf(z, 0 , 1) - log( .5*s );
    elseif Constraints(J) == 0
        s = sqrt(Sigma(J,J));
        z = (x(J) - mu(J))/s;    
        lpdf(n,1) = lpdf(n,1) + logmvnpdf(z, 0 , 1);  
    end
end

