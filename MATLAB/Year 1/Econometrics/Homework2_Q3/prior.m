function [ out ] = prior( beta )
[r,c] = size(beta');

out = mvnpdf(beta', zeros(r,1), 2*eye(r,r));

end

