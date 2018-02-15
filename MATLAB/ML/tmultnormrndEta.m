function [z] = tmultnormrndEta(a, b, alpha, beta, mu, Sigma, N)
[J,~] = size(Sigma);
L = chol(Sigma, 'lower');
Linv = inv(L);
if isrow(mu) 
    mu = mu';
end

if isrow(alpha)
    alpha= alpha';
end
if isrow(beta)
    beta = beta';
end
% precision = inv(Sigma);
% Hxx = diag(precision);
% sii = sqrt(Hxx.^(-1));
% I = eye(J);
% Hxy = zeros(J,J-1);
% for j = 1:J
%     notj = I([1:j-1, j+1:J], :);
%     Hxy(j,:) = notj * precision(j, :)';
% end
init = zeros(J,1);
notsuccess = 1;
sample = zeros(N, J);
for i = 1:N
    while notsuccess 
        for j = 1:J
            init(j) = truncNormalRand(alpha(j), beta(j), 0,1);
        end
        x = mu + L*init;
        conda = sum(a < x);
        condb = sum( x < b); 
        cond = conda+condb;
        if cond == 2*J 
            sample(i,:) = init';
            notsuccess = 0;
        else
            notsuccess = 1;
        end
    end
    notsuccess = 1;
end
z = mu' + (L*sample')'; 
end



