x= normrnd(0,1,100,1);
x = [ones(length(x),1) x];
error = normrnd(0,1,100,1);
beta = [3 6]'
y = dgp(x, beta, error)
betaOLS(x,y)
