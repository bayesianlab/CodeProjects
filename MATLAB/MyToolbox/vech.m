function[v] = vech(matA)
[M,N] = size(matA);
if (M == N)
    v  = [];
    for ii=1:M
        v = [v; matA(ii:end,ii)];
    end
else
     error('Input must be a symmetric matrix.')
end
end