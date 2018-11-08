function [pval] = kowEvalPriorsForObsModel(demeanedy, Precision, logdetPre)

K = size(demeanedy,1);
const = -0.5 * K * log(2*pi);
pval = const + .5*logdetPre -.5*demeanedy'*Precision*demeanedy;

end

