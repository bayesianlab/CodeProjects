function [x] = askEtaT(mu, Sigma, df, Constraints)
%% Constraints vector is 1 if sampling from positive region
%  -1 if sampling from negative region
J = size(Sigma,1);
L = chol(Sigma,'lower');
LL = tril(L,-1);
djj = diag(L);
x = zeros(1,J);
w = sqrt(df/chi2rnd);
if J > 1
    for j = 1:J
        newCut = -(mu(j) + (w.*LL(j,:)*x'))/djj(j);
        if Constraints(j) == 1
            x(j) = tmvn_epsilonball(newCut, 1);
        elseif Constraints(j) == -1
            x(j) = -tmvn_epsilonball(-newCut, 1);
        elseif Constraints(j) == 0
            x(j) = normrnd(0,1);
        else
            error('Constraint must be 0, 1 or -1');
        end
    end
elseif J == 1
    for j = 1:J
        if Constraints(j) == 1
            x(j) = tmvn_epsilonball(newCut, 1);
        elseif Constraints(j) == -1
            x(j) = -tmvn_epsilonball(-newCut, 1);
        elseif Constraints(j) == 0
            x(j) = normrnd(0,1);
        else
            error('Constraint must be 0, 1 or -1');
        end
    end
end
end


