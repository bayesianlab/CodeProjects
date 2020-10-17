function [lpdf] = logtmvtpdf(x, centrality, shape, df, Constraints)
J = size(shape,1);
lpdf = zeros(J,1);
for j = 1:J-1
    [cm, cv, cdf] = tconditionalmoments(x,centrality, shape, df, j);
    z = (x(j) - cm)/cv;
    alpha = 1- tcdf(-Constraints(j)*cm, cdf);
    if (Constraints(j) == 1) || (Constraints(j) == -1)
        lpdf(j) = logtpdf(z, 0, 1, cdf) - log( sqrt(cv)*alpha );
    elseif Constraints == 0
        lpdf(j) = logtpdf(z, 0, 1, cdf);
    else
        error('Constraints must be 0, 1, or -1.')
    end
    
end
[cm, cv, cdf] = tconditionalmoments(x,centrality, shape, df, J);
z = (x(J) - cm) / sqrt(cv); 
alpha = 1 - tcdf(-Constraints(J)*cm, cdf); 
if (Constraints(J) == 1) || (Constraints(J) == -1)
    lpdf(J) = logtpdf(z, 0, 1, cdf) - log( sqrt(cv)*alpha );
elseif Constraints == 0
    lpdf(J) = logtpdf(z, 0, 1, cdf);
else
    error('Constraints must be 0, 1, or -1.')
end
lpdf = sum(lpdf);
end

