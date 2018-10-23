function [stoCountryBetas, S123 ] = kowupdateBetaPriors(KowData, ObsModel,...
   vectorObservationVariances,varianceRestriction, Sworld, Sregion, Scountry,
    regionIndices, b0, B0inv)
[T, ~] = size(KowData);

PerCountryEqns = 3;
PerCountryFactors = 3;
Countries = 60;
Regions = 7;
t = 1:5;
tbeta = 1:4;
priorsMult = B0inv*b0;
Eqns = PerCountryEqns*Countries;

% USA has all three restrictions
Tvector = ones(T,1);
A = spdiags(Tvector, 0, T,T);
B = spdiags(Tvector, 0, T,T);
C = spdiags(Tvector, 0, T, T);
MatrixInverse = recursiveWoodbury(diag(ones(T,1).*...
    vectorObservationVariances(1)), A, Sworld, B, Sregion(:,:,1),...
    C, Scountry(:,:,1)) ;
newCountry = 0;
stoCountryBetas = zeros(4*Eqns,1);
for i = 1:Eqns

    newCountry = newCountry + 1;
    A = spdiags(Tvector.*ObsModel(newCountry,1), 0, T,T);
    B = spdiags(Tvector.*ObsModel(newCountry,2), 0, T,T);
    C = spdiags(Tvector, 0, T, T);
    MatrixInverse = recursiveWoodbury(diag(ones(T,1).*...
        vectorObservationVariances(1)), A, Sworld, B,...
        Sregion(:,:,region) ,C, Scountry(:,:,newCountry)) ;
    select = t + (i-1)*5;
    betaselect = tbeta + (i-1)*4;
    y = KowData(:, select(1));
    X = KowData(:,select(2:end));
    bcovarmat = (B0inv + X'*MatrixInverse*X)\eye(4);
    bmean = bcovarmat*(priorsMult + X'*MatrixInverse*y);
    stoCountryBetas(betaselect,1) = bmean +...
        chol(bcovarmat, 'lower')*normrnd(0,1,4,1);
    
end

end
