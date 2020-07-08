function [B1] = BFGS_Hessian(grad0, grad1, sk, B0)
yk = grad1 - grad0;
sktyk = sk'*yk;
skykt = sk*yk';
skyktBki = skykt*B0;
num1 = (sktyk+ yk'*B0*yk)*(sk*sk');
num2 = -(skyktBki' + skyktBki);
B1 = B0 + (num1/sktyk^2)  + (num2/sktyk);
end

