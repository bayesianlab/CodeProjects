function [ realml ] = logAvg( X )
% X is assumed to already by logged
% Storage is assumed to be [c1,c2,...cN], and average across
% second dimension
N = length(X);
maxval = max(X,[],2);
realml = log(sum(exp(X - maxval),2)) + maxval-log(N);
end

