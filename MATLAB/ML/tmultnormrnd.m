function [sample] = tmultnormrnd(a,b,mu,Sigma,N,init)
[J,~] = size(Sigma);
if isrow(mu) 
    mu = mu';
end
if isrow(init) 
    init = init';
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
means = zeros(N, J);
for i = 1:N
    for j = 1:J
        notj = I([1:j-1, j+1:J], :);
        xnot = notj*init;
        munot = notj*mu;
        means(i,j) = cmean(mu(j), Hxx(j), Hxy(j,:)', xnot, munot);
        init(j) = truncNormalRand(a(j), b(j), means(i,j), sii(j));
    end
    sample(i,:) = init;
end 
end

