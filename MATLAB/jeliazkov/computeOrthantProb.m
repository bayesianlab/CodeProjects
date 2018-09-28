function [ logprob ] = computeOrthantProb(y,mu,Sigma,sims,burnin )
% y should probably all be the same value, vector 
% for vector. 
[r, c] = size(mu);
logprob = zeros(1,c);
A = zeros(r,c);
B = zeros(r,c);
for j = 1:c
    for i = 1:r
        if y(i,j) > 0
            A(i,j) = 0;
            B(i,j) = inf;
        else
            A(i,j) = -inf;
            B(i,j) = 0;
        end
    end
   logprob(1,j) = crtorthant(A(:,j), B(:,j), mu(:,j), Sigma, sims,burnin);
end
end

