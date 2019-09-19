function [ retval, lastMean, lastCovar, otherOM] = identification2( x0, yt, obsPrecision, Ft, FtPrecision,...
    lastMean, lastCovar, x1  )
options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-18, 'Display', 'iter', 'OptimalityTolerance', 1e-18,...
    'FiniteDifferenceStepSize', 1e-17);
[K,T] = size(yt);
df = 6;
w1 = sqrt(chi2rnd(df,1)/df);
ObsPriorMean = .5.*ones(1, K);
ObsPriorPrecision = .1.*eye(K);
LL = @(guess) -LLRestrict(guess, yt,ObsPriorMean,...
    ObsPriorPrecision, obsPrecision, Ft,FtPrecision);


[themean, ~,exitflag,~,~, Hessian] = fminunc(LL, x1, options);
exitflag
[~, p] = chol(Hessian);
if p ~= 0
    themean = lastMean';
    V = lastCovar;
else
    lastMean = themean';
    lastCovar = Hessian\eye(K);
    V = lastCovar;
end
proposalDist = @(q) mvstudenttpdf(q, themean(2:end)', V(2:end,2:end), df);

LogLikePositive = @(v) LLRestrict (v, yt(2:end,:),ObsPriorMean(2:end),...
    ObsPriorPrecision(2:end,2:end), obsPrecision(2:end), Ft,FtPrecision);
proposal = themean + chol(V, 'lower')*normrnd(0,1, K,1)./w1;
otherOM = proposal;
proposal = proposal(2:end);
freeElems = x0(2:end);
Num = LogLikePositive(proposal) + proposalDist(freeElems');
Den = LogLikePositive(freeElems) + proposalDist(proposal');
alpha = Num - Den;
u = log(unifrnd(0,1,1));
if u <= alpha
    retval = [1;proposal];
else
    retval = x0;
    otherOM = x1;
end
end

