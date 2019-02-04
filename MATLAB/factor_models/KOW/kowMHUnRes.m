function [ draw ] = kowMHUnRes(notcandidate, optimalMean, Precision, ydemut,...
     obsPrecision, ObsPriorMean, ObsPriorVar, factor, StatePrecision)
Variance = Precision\eye(size(Precision,1));
df = 15;

candidate = optimalMean + chol(Variance, 'lower')*...
    normrnd(0,1,size(Variance,1),1)./(sqrt(chi2rnd(df,1,1)/df));

%% MH step
% Numerator
numLikelihood = -kowRatioLL(ydemut, candidate, ...
    ObsPriorMean, ObsPriorVar, obsPrecision, factor, StatePrecision) ;
Like = numLikelihood;
Prop = mvstudenttpdf(notcandidate', optimalMean', Variance, df);
Num = Like + Prop ;

% Denominator
denLikelihood = -kowRatioLL(ydemut, notcandidate,...
    ObsPriorMean, ObsPriorVar, obsPrecision, factor, StatePrecision) ;
Like = denLikelihood;
Prop = mvstudenttpdf(candidate', optimalMean', Variance, df);
Den = Like + Prop;
alpha = Num - Den;
if log(unifrnd(0,1,1,1)) <= alpha
    draw = candidate;
else
    draw = notcandidate;
end


end

