function [stoCountryBetas ] = kowupdateBetaPriors(KowData, CurrentObsModel,...
    vectorObservationVariances,varianceRestriction, b0, B0inv)
[T, ~] = size(KowData);

PerCountryEqns = 3;
PerCountryFactors = 3;
Countries = 60;
t = 1:5;
tbeta = 1:4;
priorsMult = B0inv*b0;
Eqns = PerCountryEqns*Countries;
S123 = zeros(T,T, PerCountryFactors, Countries);
S123(:,:,:, 1) = computeS123(CurrentObsModel(1,:), varianceRestriction, T);

Tvector = ones(T,1);
A = spdiags(Tvector.*CurrentObsModel(1,1), 0, T,T);
B = spdiags(Tvector.*CurrentObsModel(1,2), 0, T,T);
C = spdiags(Tvector.*CurrentObsModel(1,3), 0, T, T);
MatrixInverse = recursiveWoodbury(diag(ones(T,1).*...
    vectorObservationVariances(1)), A, S123(:,:,1,1), B, S123(:,:,2,1),...
    C, S123(:,:,3,1)) ;
newS = 0;
stoCountryBetas = zeros(4*Eqns,1);
for i = 1:Eqns
    if mod(i,PerCountryEqns) == 0
        newS = newS + 1;
        S123(:,:,:,newS) = computeS123(CurrentObsModel(newS,:),...
            varianceRestriction, T);
        A = spdiags(Tvector.*CurrentObsModel(newS,1), 0, T,T);
        B = spdiags(Tvector.*CurrentObsModel(newS,2), 0, T,T);
        C = spdiags(Tvector.*CurrentObsModel(newS,3), 0, T, T);
        MatrixInverse = recursiveWoodbury(diag(ones(T,1).*...
            vectorObservationVariances(1)), A, S123(:,:,1,newS), B,...
            S123(:,:,2,newS),C, S123(:,:,3,newS)) ;
    end
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
