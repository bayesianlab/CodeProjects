function [LLval] = negLikelihood(parameters, y,X) 
N=length(y);
e = y-X*parameters(1:end-1);
LLval = 5*( N*log(2*pi*parameters(end)) +  (e'*e)/parameters(end) );
end