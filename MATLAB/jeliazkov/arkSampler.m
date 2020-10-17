function [x] = arkSampler(Constraints, mu, Sigma)
J = size(Sigma,1);
Precision=Sigma\eye(J);
Pjj=diag(Precision).^(-1);
selectMat = logical(ones(J)-eye(J));
Pjnotj = zeros(J,J-1);

for j = 1:J
    Pjnotj(j,:) = Precision(j, selectMat(j,:));
end

x = zeros(J,1);
for j = 1:J
    stop = 1; 
    condmean = mu(j) - Pjj(j)*Pjnotj(j,:)*( x(selectMat(j,:)) - mu(selectMat(j,:)));  
    s = sqrt(Pjj(j));
    if Constraints(j) == 1
        z = -Constraints(j);
        while z < 0 
            stop = stop + 1;
            z = normrnd(condmean,s);
            if stop == 1000
                error('Tries reached maximum, try increasing max')
            end
        end        
    elseif Constraints(j) == -1
        z = -Constraints(j);      
        while z > 0 
            stop = stop + 1;
            z = normrnd(condmean,s);
            if stop == 1000
                error('Tries reached maximum, try increasing max')
            end
        end
    elseif Constraints(j) == 0
        z = normrnd(condmean, s);
    end
    x(j) = z;
end
end

