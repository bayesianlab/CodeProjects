function [ draw,themean,Hessian ] = kowObsModelUpdate(vecy, precision, StatePrecision, oldMean,...
    oldHessian, Restricted, PriorPre, logdetPriorPre, guess)
MaxRecursionDepth = 1;
options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
        'Display', 'iter', 'MaxIterations', 30);

[themean,Hessian] = kowOptimize(guess, vecy, StatePrecision,  precision,oldMean,...
    oldHessian, options, MaxRecursionDepth);
if Restricted == 1
    draw = kowMHR(guess,themean,Hessian,vecy,StatePrecision,precision,...
        PriorPre,logdetPriorPre);
else
    draw = kowMHUnRes(guess,themean,Hessian,vecy,StatePrecision,precision,PriorPre,...
        logdetPriorPre);
end
end

