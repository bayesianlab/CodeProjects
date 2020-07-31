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
    nz = find(fidx);
    fidx = fidx(nz);
    [L0,~,~,w] = initCovar(stateTransitions(fidx,:), factorVariance(fidx));
    if w~=0
        L0 = eye(lenght(stateTransitions(fidx,:)));
    end
    ytk = yt(k,:);
    [VAR(:,k), Xbeta(k,:)] = betaDraw(ytk(:), x(tempI,:),...
        obsPrecision(k),currobsmod(k,nz), FactorPrecision(stateTransitions(fidx,:),...
        L0, 1./factorVariance(fidx), T), b0, B0inv, T);
end
end

