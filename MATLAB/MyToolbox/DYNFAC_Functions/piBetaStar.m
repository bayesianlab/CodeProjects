function [pb] = piBetaStar(VARstar, yt, x, obsPrecision,currobsmod,...
    stateTransitions, factorVariance, b0, B0inv, subsetIndices, FtIndexMat)

[K,T] = size(yt);
pb = zeros(K,1);
for k=1:K
    tempI = subsetIndices(k,:);
    tempy = yt(k,:);
    tempx = x(tempI,:);
    tempObsPrecision = obsPrecision(k);
    fidx=FtIndexMat(k,:);
    nz = find(fidx);
    fidx = fidx(nz);
    tempOm = currobsmod(k,nz);
    
    gammas = stateTransitions(fidx,:);
    [L0, ~] = initCovar(gammas, factorVariance(fidx));
    StatePrecision = FactorPrecision(gammas, L0, 1./factorVariance(fidx), T);
    pb(k)= pibeta(VARstar(:,k), tempy(:), tempx, tempObsPrecision,...
        tempOm, StatePrecision, b0, B0inv, T);
end

end

