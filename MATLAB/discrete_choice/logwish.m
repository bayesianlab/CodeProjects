function y = logwish(X, W, v)
d = size(X,1);
B = (-0.5*v*logdet(W))-(0.5*v*d*log(2))-gammaln(.5*v);
y = B+(0.5*(v-d-1)*logdet(X))-0.5*trace(W\X);

