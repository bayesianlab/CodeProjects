function [unvech] = unVechMatrixMaker(K,d)
%% Example usage:
% c = 3x3 matrix, d=0, vech(c)
% returns a vector with diagonal included vectorized c.
% unvech x vech(c,d) = c

ndias = length(d:0)-1;
Kmd = K-ndias;
B = Kmd*(Kmd+1)/2;
setb = 1:B;
pmat = zeros(K,K);
c = 0;
for k = 1:Kmd
    for j = k:Kmd
        c=c+1;
        pmat(j+ndias,k) = setb(c);
    end
end

pindices=pmat(:);
unvech = zeros(Kmd*Kmd, B);
for k = 1:(K*K)
    if pindices(k) == 0
        unvech(k,:) = zeros(1,B);
    else
        unvech(k,pindices(k)) = 1;
    end
end

end

