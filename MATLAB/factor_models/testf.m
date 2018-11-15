function [x] = testf(L,x)
Total = size(L,1);
L = chol(L,'lower');
Li = L\speye(size(L,1));
ForwardSolved = Li*x;

upperoff = triu(L',1);
diagelems = diag(L);
eta = zeros(Total,1);
eta(Total) = ForwardSolved(Total);
epsilon = normrnd(0,1,Total,1);
x = Li*epsilon;


for t = Total:(-1):1
   eta(t) = (ForwardSolved(t) - upperoff(t,:)*eta)/diagelems(t); 
end
eta
x = (eta + x);
end

