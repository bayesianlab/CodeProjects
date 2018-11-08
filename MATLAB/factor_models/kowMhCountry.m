function [draw] = kowMhCountry(notcandidate, optimalMean, iHessian,...
    Hessian, ydemu, StatePrecision, obsPrecision, PriorPre,...
    logdetPriorPre, K, T)
df = 15;
w1 = sqrt(chi2rnd(df,1)/df);
K = size(Hessian,1);
Precision = Hessian;
% draw restricted candidate marginally
sigma = sqrt(iHessian(1,1));

restricteddraw = truncNormalRand(0, Inf, optimalMean(1), sigma)/w1;
% draw conditional candidate
[cdraw,condmean,condvar] = kowConditionalDraw(optimalMean(2:end),...
    Precision(2:end,2:end),...
    Precision(2:end, 1), Precision(1,1), restricteddraw,...
    optimalMean(1), df, df+1);
candidate = [restricteddraw;cdraw];

llhoodnum= kowOptimizeCountry(candidate, ydemu, StatePrecision,...
    obsPrecision, K, T);
llhoodden= kowOptimizeCountry(notcandidate, ydemu, StatePrecision,...
    obsPrecision, K, T);



Like = llhoodnum + kowEvalPriorsForObsModel(candidate, PriorPre, ...
    logdetPriorPre);
Prop = mvstudenttpdf(notcandidate, optimalMean, iHessian, df);
Num = Like + Prop ;

Like = llhoodden + kowEvalPriorsForObsModel(notcandidate, PriorPre, ...
    logdetPriorPre);
Prop = mvstudenttpdf(candidate, optimalMean, iHessian, df);
Den = Like + Prop;

if log(unifrnd(0,1,1,1)) < Num - Den
    fprintf('yes\n')
    draw = candidate;
else
    draw = notcandidate;
end

end

