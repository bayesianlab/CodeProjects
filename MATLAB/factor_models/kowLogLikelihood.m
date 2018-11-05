function [ll] = kowLogLikelihood(demeanedy, variance)
ll =  sum(log(normpdf(demeanedy, 0, sqrt(variance))));
end

