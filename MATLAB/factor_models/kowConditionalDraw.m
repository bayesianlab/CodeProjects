function [conditionaldraw, condmean, condvar] = kowConditionalDraw(mui, Hii, Hinoti, Hnotinoti, xnot, munot, df1, df2)
[condmean, condvar] = kowConditionalParametersT(mui, Hii, Hinoti,...
    Hnotinoti, xnot, munot, df1, df2);
conditionaldraw = condmean + chol(condvar, 'lower')*...
    normrnd(0,1,size(Hii,1),1)./ sqrt(chi2rnd(df2)/df2);
end

