function [draw, alpha] = kowMHR(notcandidate, optimalMean,Precision, ydemut,...
    obsPrecision, ObsPriorMean, ObsPriorVar, factor, StatePrecision)
n = size(Precision,1);
Variance = Precision\eye(n);
df = 20;
w1 = sqrt(chi2rnd(df,1)/df);
% % draw restricted candidate marginally
% sigma = sqrt(Variance(1,1));
% alpha = -(optimalMean(1)*w1)/sigma;
% z = truncNormalRand(alpha, Inf,0, 1);
% restricteddraw = optimalMean(1) + (sigma*z)/w1;

% % draw conditional candidate
% [cdraw,~,~] = kowConditionalDraw(restricteddraw, optimalMean, Variance, Precision, df, df+1, 1, 2:n);
% candidate = [restricteddraw;cdraw]

candidate = optimalMean(1:n) + chol(Variance(1:n,1:n), 'lower')*normrnd(0,1, n,1)./w1;
% candidate = [restricteddraw;candidate];
if candidate(1) < 0    
    sigma = sqrt(Variance(1,1));
    alpha = -(optimalMean(1)*w1)/sigma;
    z = truncNormalRand(alpha, Inf,0, 1);
    restricteddraw = optimalMean(1) + (sigma*z)/w1;
    lower = optimalMean(2:n) + chol(Variance(2:n,2:n), 'lower')*normrnd(0,1, n-1,1)./w1;
    candidate = [restricteddraw;lower];
end


%% MH step
% Numerator
Like = -kowRatioLL(ydemut, candidate, ...
    ObsPriorMean, ObsPriorVar, obsPrecision, factor, StatePrecision) ;

Prop = mvstudenttpdf(notcandidate', optimalMean', Variance, df);
Num = Like + Prop ;
% Denominator
Like = -kowRatioLL(ydemut, notcandidate,...
    ObsPriorMean, ObsPriorVar, obsPrecision, factor, StatePrecision) ;
Prop = mvstudenttpdf(candidate', optimalMean', Variance, df);
Den = Like + Prop;

if log(unifrnd(0,1,1,1)) <= (Num - Den)
    draw = candidate;
else
    draw = notcandidate;
end

end

