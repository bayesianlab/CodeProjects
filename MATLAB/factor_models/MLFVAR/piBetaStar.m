function [pb] = piBetaStar(VARstar, yt, x, obsPrecision,currobsmod,...
    stateTransitions, factorVariance, betaPriorMean, betaPriorPre, subsetIndices, FtIndexMat)

[K,T] = size(yt);
pb = zeros(K,1);
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
    pb(k)= pibeta(VARstar(:,k), tempy(:), tempx, tempObsPrecision,...
        tempOm, StatePrecision, betaPriorMean, betaPriorPre, T);
end

end

