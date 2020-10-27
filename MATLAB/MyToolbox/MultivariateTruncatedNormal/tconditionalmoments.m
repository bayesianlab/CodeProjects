function [condmean, condvar, df12] = tconditionalmoments(x, centrality, shape, df, index)
[K, ~] = size(shape);
if ~isrow(x)
    error('x must be row')
elseif ~isrow(centrality)
    error('centrality must be row')
end

centered = x - centrality;
Precision = shape\eye(K);
Pjj=diag(Precision).^(-1);
selectMat = logical(ones(K)-eye(K));
notj = selectMat(index,:);
df12 = df +K-1;
condmean = centrality(index) - (Pjj(index)*(Precision(index, notj)*centered(notj)'));
condvar = ((df + centered(notj)*shape(notj, notj)*centered(notj)')/(df+K-1))*Pjj(index);
end

