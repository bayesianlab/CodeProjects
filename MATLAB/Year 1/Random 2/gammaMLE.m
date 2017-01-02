% gammaMLE
% Y is vector of draws on g.dist. 
% rGams contains the data and is inside script of importGammaData
importGammaData;
options = optimoptions('fminunc', 'GradObj', 'on');
startPoint = [1;1];
gFunc = @(startPoint)gammaNegLogLikelihood(startPoint, rGams);
[x, fval, exitflag, output, grad, hessian] = fminunc(gFunc, ...
    startPoint, options)
