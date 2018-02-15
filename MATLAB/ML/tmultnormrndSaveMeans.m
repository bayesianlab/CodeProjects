function [sample, means] = tmultnormrndSaveMeans(a,b,mu,Sigma,N)
[J,~] = size(Sigma);
if isrow(mu) == 0
    mu = mu';
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
updateVec = zeros(J,1);
sample = zeros(N, J);
means = zeros(N, J);
for i = 2:N
    for j = 1:J
        notj = I([1:j-1, j+1:J], :);
        muxy = notj*mu';
        xnot = notj*updateVec;
        cm = cmean(mu(j), Hxx(j), Hxy(j,:)', xnot, muxy);  
        means(i,j) = cm;
        updateVec(j) = truncNormalRand(a(j), b(j), cm, sii(j));
    end
    sample(i,:) = updateVec;
end
end
