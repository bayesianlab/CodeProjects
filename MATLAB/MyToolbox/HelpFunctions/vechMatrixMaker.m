function [VechMat, VechIndex] = vechMatrixMaker(Sigma,d)
if d > 0 
    error('d must be zero or less than 0.')
end
[K,T]=size(Sigma);
if K ~=T
    error('Input must be square.')
end
if d == 0
    B = K*(K+1)/2;
    Kmd = K;
else
    Kmd = K-abs(d);
    B = (Kmd)*(Kmd-1)/2;
end
VechMat = zeros(B,K*K);
VechIndex = zeros(B,2);
r = 1;
c=length(d:0);
for col = 1:Kmd 
    for row = c:K
        index = K*(col-1) + row;
        VechMat(r,index) =1;
        r=r+1;
    end
    c= c+1;
end
end

