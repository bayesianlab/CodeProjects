function [VAR, Xbeta] = VAR_ParameterUpdate(yt, x, obsPrecision,...
    currobsmod, stateTransitions, factorVariance, betaPriorMean, betaPriorPre, FtIndexMat, subsetIndices)

[K,T] = size(yt);
[~, dimx] = size(x);
VAR = zeros(dimx, K);
Xbeta = zeros(K, T);
for k=1:K
    tempI = subsetIndices(k,:);
    tempy = yt(k,:);
    tempx = x(tempI,:);
    tempObsPrecision = obsPrecision(k);
    tempOm = currobsmod(k,:);
    fidx=FtIndexMat(k,:);
    gammas = stateTransitions(fidx,:);
    [L0, ssgam] = initCovar(diag(gammas));
    StatePrecision = FactorPrecision(ssgam, L0, 1./factorVariance(fidx), T);
    [VAR(:,k), Xbeta(k,:)] = betaDraw(tempy(:), tempx,...
        tempObsPrecision,tempOm,StatePrecision, betaPriorMean, betaPriorPre, T);
end
end

