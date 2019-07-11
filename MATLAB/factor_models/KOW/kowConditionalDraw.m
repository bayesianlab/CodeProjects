function [conditionaldraw, condmean, condvar] =...
    kowConditionalDraw(xcondOn, mu, Variance, Precision, df1, df2, conditionedOn, notcond)
demurestrict = xcondOn(conditionedOn)-mu(conditionedOn);
lnotcond = length(notcond);
HiiHinoti = Precision(notcond,notcond)\Precision(notcond,conditionedOn);
condmean = mu(notcond) - HiiHinoti*demurestrict;
condvar = (df1 + ((demurestrict'\Variance(conditionedOn,conditionedOn) *demurestrict) )/ df2)...
    *(Precision(notcond,notcond)\eye(lnotcond));
conditionaldraw = condmean + chol(condvar, 'lower')*...
    normrnd(0,1,lnotcond,1)./ sqrt(chi2rnd(df2)/df2);
end

