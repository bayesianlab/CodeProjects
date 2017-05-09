function [ samp ] = drawNTruncatedMVNs(N, bigDraw, mu, sigma, stop)
J = length(mu);
count = 0;
i = 1;
c =0;
samp = zeros(N,J);
emptyRows = N;
while c < stop
    c = c + 1;
    z =mvnrnd(mu, sigma, bigDraw);    
    keep = z(sum(z > 0,2) == J,:);
    [r,~] = size(keep);
    if r < emptyRows && r > 0 
        samp(i:i+r-1,:) = keep;
        emptyRows = emptyRows - r;
        i = i + r;
    elseif r >= emptyRows
        samp(i:N, :) = keep(1:emptyRows,:);
        return
    elseif c == stop
        samp = NaN;
        return
    end
end

end

