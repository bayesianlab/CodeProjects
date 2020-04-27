function[ypred] = SimPrediction(ConditionalMean, Variance)
ypred = ConditionalMean;
N = length(ConditionalMean);
for n = 1:N
    ypred(n) = normrnd(ConditionalMean(n), Variance(n), 1,1);
end

end