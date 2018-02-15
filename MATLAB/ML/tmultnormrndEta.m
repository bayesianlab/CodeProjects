function [z] = tmultnormrndEta(alpha, beta, mu, Sigma, N, init)
[J,~] = size(Sigma);
L = chol(Sigma, 'lower');
Linv = inv(L);
if isrow(mu) 
    mu = mu';
end
if isrow(init)
    init = init';
end
if isrow(alpha)
    alpha= alpha';
end
if isrow(beta)
    beta = beta';
end
precision = inv(Sigma);
Hxx = diag(precision);
sii = sqrt(Hxx.^(-1));
I = eye(J);
Hxy = zeros(J,J-1);
for j = 1:J
    notj = I([1:j-1, j+1:J], :);
    Hxy(j,:) = notj * precision(j, :)';
end

sample = zeros(N, J);
for i = 1:N
    for j = 1:J
        notj = I([1:j-1, j+1:J], :);
        muxy = notj*mu;
        xnot = notj*init;
        cmean = zeroMeanMultiVarNormCmean(Hxx(j), Hxy(j,:)', xnot);
        init(j) = truncNormalRand(alpha(j), beta(j), 0, 1);
    end
    sample(i,:) = init';
end
z = mu' + (L*sample')'; 
end



