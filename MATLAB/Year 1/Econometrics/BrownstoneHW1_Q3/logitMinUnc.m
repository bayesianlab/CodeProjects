function [ estimator, log_like, exitf, output, g, h ] = logitMinUnc( guess,X,y )
c_initial = guess;

[estimator,log_like, exitf, output, g, h ]=fminunc(@(c)maxLikelihoodLogit(c,X,y),...
    c_initial);

end