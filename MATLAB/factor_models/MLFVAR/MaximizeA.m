function [themean, V, lastMean, lastCovar] = MaximizeA(x0, yt, obsPrecision, Ft, FtPrecision,...
    lastMean, lastCovar, options, Restricted )
if Restricted == 1
    [K,T] = size(yt);
    ObsPriorMean = ones(1, K-1);
    ObsPriorPrecision = .5.*eye(K-1);
    LL = @(guess) -LLRestrict(guess, yt,ObsPriorMean,...
        ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
    [themean, ~,exitflag,~,~, Hessian] = fminunc(LL, x0, options);
    [~, p] = chol(Hessian);
    if p ~= 0
        themean = lastMean';
        V = lastCovar;
    else
        lastMean = themean';
        lastCovar = Hessian\eye(K-1);
        V = lastCovar;
    end
else
    [K,T] = size(yt);
    ObsPriorMean = ones(1, K);
    ObsPriorPrecision = .5.*eye(K);
    LL = @(guess) -AproptoLL(guess, yt,ObsPriorMean,...
        ObsPriorPrecision, obsPrecision, Ft,FtPrecision);
    [themean, ~,exitflag,~,~, Hessian] = fminunc(LL, x0, options);
    [~, p] = chol(Hessian);
    if p ~= 0
        themean = lastMean';
        V = lastCovar;
    else
        lastMean = themean';
        lastCovar = Hessian\eye(K);
        V = lastCovar;
    end
end
end

