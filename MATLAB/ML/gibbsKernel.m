function [Kernel] = gibbsKernel(a,b,mu,Sigma,sample)
if isrow(mu)
    mu = mu';
end
[N,J] = size(sample);
Kernel = zeros(N,J);
precision = inv(Sigma);
Hxy = zeros(J,J-1);
I = eye(J);
for j = 1:J
    notj = I([1:j-1, j+1:J], :);
    Hxy(j,:) = notj * precision(j, :)';
end
zStar = mean(sample)';
xnotj = sample(:,2:J);
Hxx = diag(precision);
sxx = sqrt(Hxx.^(-1));
Kernel(:, 1) = tnormpdf(a(1), b(1),...
    condMeanXMat(mu(1), Hxx(1),  Hxy(1,:)', xnotj', mu(2:J)), sxx(1), zStar(1));
for j = 2:J-1
   notj = I([1:j-1, j+1:J], :);
   munot = notj*mu;
   xnotj(:, j-1) = zStar(j-1,1);
   Kernel(:, j) = tnormpdf(a(j), b(j),...
    condMeanXMat(mu(j), Hxx(j),  Hxy(j,:)', xnotj', munot), sxx(j), zStar(j));
end
Kernel(:, J) = tnormpdf(a(J), b(J),...
    cmean(mu(J), Hxx(J), Hxy(J,:)', zStar(1:J-1,1), mu(1:J-1,1)),...
    sxx(J), zStar(J));
end

