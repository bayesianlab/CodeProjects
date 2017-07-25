function [ rv ] = shiftexprnd(a,b,mu, N, p)
if b == Inf
    rv = (a.*mu - (log(1 -  unifrnd(0,1,N,p)))) ./ mu;
else
    q = 1 - exp(-mu*(b-a));
    rv = (a.*mu - (log(1 -  (q*unifrnd(0,1,N,p))))) ./ mu;
end

