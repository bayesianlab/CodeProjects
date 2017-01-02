clc
a=1
A=4
beta=0.9
nbk	= 10;
k		= linspace(0,1,nbk)';
k
v0		= zeros(nbk,1);
v		= zeros(nbk,1);
iter	= 1;
crit	= 1;
tol	= 1e-6;
cnt = 0
while iter < 10;
   for i=1:nbk
      c			= A*k(i)-k;
      u			= c-(a/2)*c.^2;
      u
      [v(i),itmp]	= max(u+beta*v0);
      
   end;
   crit	= max(abs(v-v0));
   v0		= v;
   iter	= iter+1;
end
plot(k,v0);