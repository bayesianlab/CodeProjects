function [sample] = arSample(a,b,mu,sigma, N)
[J,~] = size(sigma);
n = 1;
sample = zeros(N,J);
while n <= N
    z = mvnrnd(mu,sigma, 1);
    if sum(z>a & z < b,2) == J
        sample(n,:) = z;
        n = n +1 ;
    end
end
end

