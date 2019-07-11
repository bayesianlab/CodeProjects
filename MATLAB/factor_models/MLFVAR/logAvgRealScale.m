function [ realml ] = logAvgRealScale( X )
% X is assumed to already be logged
% Storage is assumed to be [c1,c2,...cN], and average across
% second dimension
N = length(X);
maxval = max(X,[],2);
realml = 
end
