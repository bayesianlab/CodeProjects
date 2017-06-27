function [ sample ] = arDraw(a,b, mu ,sigma, draws)
[J,~] = size(sigma);
z = mvnrnd(mu,sigma, draws);
sample = z((sum(z>a & z < b,2) == J),:);
end

