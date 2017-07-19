function [ rv ] = shiftexprnd(mu, shift, N, p)
rv = (shift.*mu - (log(1 - unifrnd(0,1,N,p)))) ./ mu;
end

