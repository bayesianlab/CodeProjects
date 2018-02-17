function [sample] = arSample(a,b,mu,sigma, N)
[J,~] = size(sigma);
n = 1;
sample = zeros(N,J);
Lim = 100000;
maxiterations = 0;
while (n <= N) && (maxiterations < Lim)
        z = mvnrnd(mu,sigma,1)';
        cond = sum(a < z) + sum(z < b);
        if cond == 2*J
            sample(n,:) = z;
            n = n + 1;
        else
            maxiterations = maxiterations + 1;
        end        
end
end

