function [z] = updateLatentZ(y,mu,Sigma, init)
[r, c] = size(mu);
z = zeros(r,c);
A = zeros(r,c);
B = zeros(r,c);
for i = 1:r
    for j = 1:c
        if y(i,j) > 0
            A(i,j) = 0;
            B(i,j) = inf;
        else
            A(i,j) = -inf;
            B(i,j) = 0;
        end
    end
    z(i,:) = tmultnormrnd(A(i,:), B(i,:), mu(i,:), Sigma, 1, init(:,i));
end
end



