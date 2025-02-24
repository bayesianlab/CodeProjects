function [draw, alpha] = kowMhRestricted(notcandidate, optimalMean, iHessian,...
    Hessian, ydemu, StatePrecision, obsPrecision, PriorPre,...
    logdetPriorPre)
df = 15;
w1 = sqrt(chi2rnd(df,1)/df);
% draw restricted candidate marginally
sigma = sqrt(iHessian(1,1));
restricteddraw = optimalMean(1)+ truncNormalRand(0, Inf,0, sigma)/w1;

% draw conditional candidate
[cdraw,~,~] = kowConditionalDraw(optimalMean(2:end),...
    Hessian(2:end,2:end), Hessian(2:end, 1), Hessian(1,1), restricteddraw,...
    optimalMean(1), df, df+1);
candidate = [restricteddraw;cdraw];

%% MH step
% Numerator
llhoodnum= kowLL(candidate, ydemu, StatePrecision,...
    obsPrecision);
Like = llhoodnum + kowEvalPriorsForObsModel(candidate, PriorPre, ...
    logdetPriorPre);
Prop = mvstudenttpdf(notcandidate, optimalMean, iHessian, df);
Num = Like + Prop ;

% Denominator
llhoodden= kowLL(notcandidate, ydemu, StatePrecision,...
    obsPrecision);
Like = llhoodden + kowEvalPriorsForObsModel(notcandidate, PriorPre, ...
    logdetPriorPre);
Prop = mvstudenttpdf(candidate, optimalMean, iHessian, df);
Den = Like + Prop;
alpha = Num - Den;
if log(unifrnd(0,1,1,1)) <= alpha
    draw = candidate;
else
    draw = notcandidate;
end

end

