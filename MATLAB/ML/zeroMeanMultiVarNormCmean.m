function [cmean] = zeroMeanMultiVarNormCmean(Hxx, Hyx, xNotj)
cmean  = - (1/Hxx)*Hyx'*xNotj;
end

