function [x] = arkTSampler(Constraints, mu, Sigma, df)
J = size(Sigma,1);
Precision=Sigma\eye(J);
Pjj=diag(Precision).^(-1);
selectMat = logical(ones(J)-eye(J));
Pjnotj = zeros(J,J-1);

for j = 1:J
    Pjnotj(j,:) = Precision(j, selectMat(j,:));
end
MaxTries = 1000;
x = zeros(J,1);
w = sqrt(df/chi2rnd(df));
for j = 1:J
    stop = 1; 
    condmean = mu(j) - Pjj(j)*Pjnotj(j,:)*( x(selectMat(j,:)) - mu(selectMat(j,:)));  
    s = sqrt(Pjj(j));
    if Constraints(j) == 1
        z = -Constraints(j);
        while z < 0 
            stop = stop + 1;
            z = w*normrnd(condmean,s);
            if stop == MaxTries
                z=NormalTruncatedTPositive(condmean, Pjj(j), df, 1);
                break
            end
        end        
    elseif Constraints(j) == -1
        z = -Constraints(j);      
        while z > 0 
            stop = stop + 1;
            z = w*normrnd(condmean,s);
            if stop == MaxTries
                z=-NormalTruncatedTPositive(-condmean,Pjj(j), df, 1);
                break
            end
        end
    elseif Constraints(j) == 0
        z = w*normrnd(condmean, s);
    end
    x(j) = z;
end
end