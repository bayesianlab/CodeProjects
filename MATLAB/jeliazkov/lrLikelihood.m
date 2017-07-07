function [ like ] = lrLikelihood(y,X,beta,sigmasqd)
% Beta = (beta11...beta1N;beta21, ...,beta2N)
% sigmasqd in row
N = length(y);
e = y - X*beta;
normc = (log(2.*pi.*sigmasqd).*(-N/2))';
expnormc = -(2.*sigmasqd).^(-1)';
like = normc + expnormc.*sum(e.*e)';
end

