alpha = 100.5;
beta = 3.125;
Y = gamrnd(alpha, beta, 100000, 1) ;
clearvars raw;
options = optimoptions('fminunc', 'GradObj', 'on');
startPoint = [1;1];
gammaNegLogLikelihood(startPoint, Y);
gFunc = @(startPoint)gammaNegLogLikelihood(startPoint, Y);
[x, fval, exitflag, output, grad, hessian] = fminunc(gFunc, startPoint, options)


