function [ derivs] = richardsonExtra(n, beta, eps, del)
r = length(beta);
derivArray1 = zeros(n,n);
h = eye(r).*del;
for i = 1:n
    LLup = ARmethodSimulateMoments(beta+h(:,1),eps);
    LLdown = ARmethodSimulateMoments(beta-h(:,1),eps);
    derivArray1(i,1) = -(LLup - LLdown )/(2*del);
    for j = 2:i
        derivArray1(i,j) =  derivArray1(i,j-1) +...
            ((derivArray1(i,j-1) - derivArray1(i-1,j-1)/((4^j) - 1)));
    end
end
derivArray2 = zeros(n,n);
for i = 1:n
    LLup = ARmethodSimulateMoments(beta+h(:,2),eps);
    LLdown = ARmethodSimulateMoments(beta-h(:,2),eps);
    derivArray2(i,1) = -(LLup - LLdown )/(2*del);
    for j = 2:i
        derivArray2(i,j) =  derivArray2(i,j-1) +...
            ((derivArray2(i,j-1) - derivArray2(i-1,j-1)/((4^j) - 1)));
    end
end
derivs = [derivArray1(n,n);derivArray2(n,n)];
end

