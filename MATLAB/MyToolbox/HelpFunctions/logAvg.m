function [ realml ] = logAvg( X )
% X is assumed to already be logged
% Storage is assumed to be [c1,c2,...cN], and average across
% second dimension
N = size(X,2);
maxval = max(X,[],2);
realml = log(sum(exp(X - maxval),2)) + maxval-log(N);
end

