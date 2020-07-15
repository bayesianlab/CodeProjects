function [VAR, Xbeta] = VAR_ParameterUpdate(yt, x, obsPrecision,...
    currobsmod, stateTransitions, factorVariance, b0, B0inv,...
    FtIndexMat, subsetIndices)
[K,T] = size(yt);
[~, dimx] = size(x);
VAR = zeros(dimx, K);
Xbeta = zeros(K, T);
lags = size(stateTransitions,2);
for k=1:K
    tempI = subsetIndices(k,:);
    fidx=FtIndexMat(k,:);
    L0 = initCovar(stateTransitions(fidx,:), factorVariance(fidx));
    [VAR(:,k), Xbeta(k,:)] = betaDraw(yt(k,:), x(tempI,:),...
        obsPrecision(k),currobsmod(k,:), FactorPrecision(stateTransitions(fidx,:),...
        L0, 1./factorVariance(fidx), T), b0, B0inv, T);
end
end

