function [stoCountryBetas, demeanedys ] = kowupdateBetaPriors(KowData, ObsModel,...
   vectorObservationVariances,varianceRestriction, Sworld, Sregion, Scountry,...
    regionIndices, b0, B0inv)
[T, ~] = size(KowData);

PerCountryEqns = 3;
PerCountryFactors = 3;
Countries = 60;

t = 1:5;
tbeta = 1:4;
priorsMult = B0inv*b0;
Eqns = PerCountryEqns*Countries;

% USA has all three restrictions
Tvector = ones(T,1);
newCountry = 0;
region = 1;
stoCountryBetas = zeros(4*Eqns,1);
demeanedys = zeros(T, Eqns);
for i = 1:Eqns
    if mod(i-1,3) == 0
        newCountry = newCountry + 1;
    end
    if newCountry == regionIndices(region+1)
        region = region + 1;
    end
    A = spdiags(Tvector.*ObsModel(i,1), 0, T, T);
    B = spdiags(Tvector.*ObsModel(i,2), 0, T, T);
    C = spdiags(Tvector.*ObsModel(i,3), 0, T, T);
    MatrixInverse = recursiveWoodbury(diag(ones(T,1).*...
        vectorObservationVariances(1)), A, Sworld, B,...
        Sregion(:,:,region) ,C, Scountry(:,:,newCountry)) ;
    select = t + (i-1)*5;
    betaselect = tbeta + (i-1)*4;
    y = KowData(:, select(1));
    X = KowData(:,select(2:end));
    bcovarmat = (B0inv + X'*MatrixInverse*X)\eye(4);
    bmean = bcovarmat*(priorsMult + X'*MatrixInverse*y);
    cbeta = bmean +...
        chol(bcovarmat, 'lower')*normrnd(0,1,4,1);
    demeanedys(:, i) = y - X*cbeta;
    stoCountryBetas(betaselect,1) = cbeta;
end

end
