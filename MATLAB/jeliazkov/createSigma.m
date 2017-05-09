function [ sigma ] = createSigma( rho, J)

for i = 1:J-1
    r(i) = rho^i;
end
r = [1, r]';
fr = flip(r);
A = zeros(J,J);
A(:,1) = r;
for i = 1:J-1
    A(:,i+1) = [zeros(i,1); flip(fr(i+1:J))];
end
sigma=A+ triu(flip(A(:, flip(1:J))), 1);
end

