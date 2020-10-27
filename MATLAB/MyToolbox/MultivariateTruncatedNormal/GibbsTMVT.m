function [gibbsout] = GibbsTMVT(Constraints, mu, Sigma, df, N, bn)
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
gibbsout=zeros(J,N);
x = mu;
if J > 1
    
    for n = 1:N
        for j = 1:J
            demean = x(selectMat(j,:)) - mu(selectMat(j,:));
            condmean = mu(j) - Pjj(j)*Pjnotj(j,:)*demean;
            if Constraints(j) == 1
                x(j) = NormalTruncatedTPositive(condmean, Pjj(j), df, 1);
            elseif Constraints(j) == -1
                x(j) = -NormalTruncatedTPositive(-condmean,Pjj(j), df, 1);
            elseif Constraints(j) == 0
                W = sqrt( df/chi2rnd(df));
                x(j) = condmean + W.*sqrt(Pjj(j))*normrnd(0,1);
            else
                error('Constraint must be 0, 1 or -1');
            end
        end
        gibbsout(:,n) = x;
    end
    if bn ~=0
        gibbsout=gibbsout(:,bn:end);
    end
elseif J == 1
    for n = 1:N
        for j = 1:J
            condmean = mu(j);
            if Constraints(j) == 1
                x(j) = NormalTruncatedTPositive(condmean, Pjj(j), W, 1);
            elseif Constraints(j) == -1
                x(j) = -NormalTruncatedTPositive(-condmean,Pjj(j), W, 1);
            elseif Constraints(j) == 0
                W = sqrt( df/chi2rnd(df));
                
                x(j) = condmean + W*normrnd(0,1);
            else
                error('Constraint must be 0, 1 or -1');
            end
        end
        gibbsout(:,n) = x;
    end
    if bn ~=0
        gibbsout=gibbsout(:,bn:end);
    end
end

