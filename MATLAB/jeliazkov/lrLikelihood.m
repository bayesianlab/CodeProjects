function [ like ] = lrLikelihood(y,X,beta,sigmasqd)
% Beta = (beta11...beta1N;beta21, ...,beta2N)
% sigmasqd in row
N = length(beta);
e = y - X*beta;
normc = (2.*pi.*sigmasqd).^(-N/2)';
% Mat = sum(yMxB.*yMxB,1)';
expnormc = -(2.*sigmasqd).^(-1)';
% kernel = exp( expnormc.* Mat );
% like = (normc .* kernel);
like = normc + expnormc.*sum(e.*e)';
end

