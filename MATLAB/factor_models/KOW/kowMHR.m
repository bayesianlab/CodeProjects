function [draw, alpha] = kowMHR(notcandidate, optimalMean,Precision, ydemu,...
    StatePrecision, obsPrecision, PriorPre, logdetPriorPre)
n = size(Precision,1);
Variance = Precision\eye(n);
df = 15;
w1 = sqrt(chi2rnd(df,1)/df);
% draw restricted candidate marginally
sigma = sqrt(Variance(1,1));
alpha = -(optimalMean(1)*w1)/sigma;
z = truncNormalRand(alpha, Inf,0, 1);
restricteddraw = optimalMean(1) + (sigma*z)/w1;

% draw conditional candidate
[cdraw,~,~] = kowConditionalDraw(restricteddraw, optimalMean, Variance, Precision, df, df+1, 1, 2:n);
candidate = [restricteddraw;cdraw];

%% MH step
% Numerator
llhoodnum= kowLL(candidate, ydemu, StatePrecision,...
    obsPrecision);
Like = llhoodnum + kowEvalPriorsForObsModel(candidate, PriorPre, ...
    logdetPriorPre);
Prop = mvstudenttpdf(notcandidate, optimalMean, Variance, df);
Num = Like + Prop ;

% Denominator
llhoodden= kowLL(notcandidate, ydemu, StatePrecision,...
    obsPrecision);
Like = llhoodden + kowEvalPriorsForObsModel(notcandidate, PriorPre, ...
    logdetPriorPre);
Prop = mvstudenttpdf(candidate, optimalMean, Variance, df);
Den = Like + Prop;
alpha = Num - Den;
if log(unifrnd(0,1,1,1)) <= alpha
    draw = candidate;
else
    draw = notcandidate;
end

end

