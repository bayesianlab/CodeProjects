function[Ftpred] = SimPredictionFt(ConditionalMean, factorVariance)
Ftpred=ConditionalMean;
N=length(ConditionalMean);
for n = 1:N
    Ftpred(n) = normrnd(ConditionalMean(n), factorVariance(n));
end
end