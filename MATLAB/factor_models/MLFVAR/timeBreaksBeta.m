function [beta, xbt, mean, Var] = timeBreaksBeta(yt, Xt, ItA, ItSigmaInverse, Si)
[K, T ] = size(yt);
dimX = size(Xt,2);
B0 = eye(dimX);
Q1 = ItSigmaInverse*ItA;
InsideInverse = (Si + Q1'*ItA)\eye(size(Si,1));
SigmaInverse = ItSigmaInverse - Q1*InsideInverse*Q1';
Var = ( B0 + Xt'*SigmaInverse*Xt ) \ eye(dimX);
mean = Var* (Xt'*SigmaInverse*yt(:));
beta = mean + chol(Var,'lower')*normrnd(0,1,dimX,1);
xbt = reshape(Xt*beta, K,T) ;
end

