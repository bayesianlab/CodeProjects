function [estimator,log_like, exitf, output, grad, h] = maxOrdinalMinUnc( g, ss, X, y )

[estimator,log_like, exitf, output, grad, h ]= fminunc(@(x)ordinal_LL(x, ss, X,y),...
    g);


end

