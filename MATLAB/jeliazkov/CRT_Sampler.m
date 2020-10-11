function [Kernel] = CRT_Sampler(x, Constraints, mu, Sigma, start)
%% Constraints vector is 1 if sampling from positive region
%  -1 if sampling from negative region
%% Expects column for mu
J = size(Sigma,1);
Precision=Sigma\eye(J);
Pjj=diag(Precision).^(-1);
selectMat = logical(ones(J)-eye(J));
Pjnotj = zeros(J,J-1);

for j = 1:J
    Pjnotj(j,:) = Precision(j, selectMat(j,:));
end
Kernel = zeros(J,1);
for j = start:J
    if Constraints(j) == 1 || Constraints(j) == -1
        condmean = mu(j) - Pjj(j)*Pjnotj(j,:)*( x(selectMat(j,:)) - mu(selectMat(j,:)));
        s = sqrt(Pjj(j));
        z = (x(j) - condmean)/s ; 
        Kernel(j,1) = Kernel(j,1) + logmvnpdf(z, 0, 1) - log( .5*s );     
    elseif Constraints(j) == 0 
        condmean = mu(j) - Pjj(j)*Pjnotj(j,:)*( x(selectMat(j,:)) - mu(selectMat(j,:)));
        s = sqrt(Pjj(j));
        z = (x(j) - condmean)/s ; 
        Kernel(j,1) =Kernel(j,1) + logmvnpdf(z, 0, 1);
    else
        error('Constraint must be 0, 1 or -1');
    end
end
Kernel = sum(Kernel);
end

