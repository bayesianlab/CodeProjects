function [ z] = updateLatentZTest( y,mu,Sigma,latent)
[r, c] = size(mu);
z = zeros(r,c);
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
   z(:,j) =mean( geweke91(A(:,j), B(:,j), mu(:,j), Sigma, 10,5,zeros(r,1)),2);
%    z(:,j) = geweke91(A(:,j), B(:,j), mu(:,j), Sigma, 10,9,zeros(r,1));
end
end


