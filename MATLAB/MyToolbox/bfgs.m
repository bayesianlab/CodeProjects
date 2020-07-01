function [xkk, Bki] = bfgs(xk, Bki, Function)
Bkki = Bki;
CalcGrad = @(guess) FiniteDifferencer(guess, Function, 1);
gradk = CalcGrad(xk);
opts =  optimoptions(@fmincon, 'Display', 'off', 'FiniteDifferenceType', 'forward');
K = 30;
alphak = 1;
opttol = 1e-4;
for k = 1:K
    pk = -Bkki*gradk;
    LineSearch = @(alpha) Function(xk + alpha*pk);
    alphak  = fmincon(LineSearch, alphak, [],[],[],[],0, Inf,[],opts);
    sk = alphak * pk;
    xkk = xk + sk;
    stop2 = norm(xk - xkk);
    fvalk = Function(xk);
    xk = xkk;
    stop1 = max(abs(gradk)) ;
    if stop1 < opttol || stop2 < opttol
        break
    end
    gradkk = CalcGrad(xkk);
    yk = gradkk - gradk;
    sktyk = sk'*yk;
    skykt = sk*yk';
    skyktBki = skykt*Bki;
    num1 = (sktyk+ yk'*Bki*yk)*(sk*sk');
    num2 = -(skyktBki' + skyktBki);
    Bkki = Bki + (num1/sktyk^2)  + (num2/sktyk);
    Bki = Bkki ;
    gradk = gradkk;
    fvalkk = Function(xkk);
    if abs(fvalkk-fvalk) < opttol
         break
    end
%     fprintf('%i   %3g\n', k, fvalkk)
end
end

