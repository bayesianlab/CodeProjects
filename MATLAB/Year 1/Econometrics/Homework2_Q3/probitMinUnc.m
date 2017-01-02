function [ estimates, fval, output, exitflag, grad, hessian_LOGIT ] = probitMinUnc( guess, Y, X )
c_initial = guess;

[estimates, fval, output, exitflag, grad, hessian_LOGIT ]=fminunc(@(c)maxLikelihoodProbit(c,Y,X),c_initial);

end

