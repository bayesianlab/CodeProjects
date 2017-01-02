function [olsEst, ses, tStats, tCrit, res] = betaLS(X,y, nullHypothesis, ci,...
    altEnum, dispBool )
% Returns nx1 matrix n is length of data input.
% Include a column of 1's for constant. 
% olsEst(1,1) = b_0 and olsEst(2,1) = b_ols

if isrow(y) == 1
    y = y';
end
if isrow(X) == 1
   X = X';
end
if nargin < 5
    altEnum = 2;
end
[obs, df] = size(X);
if nargin > 2
    lNull = length(nullHypothesis);
    if (lNull ~= df);
        disp('Error, null not specified correctly.')
        olsEst = NaN;
        ses = NaN;
        tStats = NaN;
        tCrit = NaN;
        res = NaN;
        return
    end
end

obsLessDegFree = obs - df;
obs = length(y);
unos = ones(obs, 1);
xPrimeXinv = inv(X' * X);
olsEst = (xPrimeXinv) * (X'* y);
res = y - X*olsEst;
resSqd = res .* res;
estVar = (resSqd' * unos)/ (obsLessDegFree);
ses = diag( sqrt(estVar * xPrimeXinv) );
results = [olsEst, ses];

if nargin > 2
    [tStats, tCrit] = tstatistic(results, nullHypothesis, ci, obsLessDegFree, altEnum);
    ests_ses_tStats = [results tStats];
    if nargin > 5
        if  dispBool == 1
            str = sprintf('  LS Est.s    S.E.s    T Stats');
            disp(str)
            disp(ests_ses_tStats)
            str = sprintf('T-critical value: %.4f', tCrit);
            disp( sprintf( 'N. observations: %i', obs) );
            disp(str)
            disp(sprintf(['Level: %.4f \n%i Sided Alternative'...
                '\nDegrees of Freedom: %i'], ci, altEnum, df))

        end
    end
else
    ses = 0;
    tStats = 0;
    tCrit = 0;
end
    
end
