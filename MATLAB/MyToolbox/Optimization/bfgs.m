function [x1, B0] = bfgs(x0, B0, Function, MaxIterations)
B1 = B0;
CalcGrad = @(guess) FiniteDifferencer(guess, Function, 1);
grad0 = CalcGrad(x0);
p0 = -B1*grad0;
opts =  optimoptions(@fmincon, 'Display', 'off', 'FiniteDifferenceType', 'forward');

alpha0 = 0;
alpha1 =  1;
opttol = 1e-4;
xdifftol = 1e-4;
% fprintf('Iteration  F. Value\n')
for k = 1:MaxIterations
    Phi = @(a) Function(x0 + a.*p0);
    DPhi = @(a) CalcGrad(x0 + a.*p0)'*p0;
    LS = @(alpha) Function(x0 + alpha*p0);
    
%     alpha1 = LS_BackTrack(1, Phi, DPhi);
% Faster
    alpha1  = fmincon(LS, alpha1, [],[],[],[],0, Inf,[],opts);
    
    sk = alpha1 * p0;
    x1 = x0 + sk;
    stop2 = norm(x0 - x1);
    fval0 = Function(x0);
    stop1 = max(abs(grad0));
    if stop1 < opttol || stop2 < xdifftol
        break
    end
    grad1 = CalcGrad(x1);
    p0 = -B1*grad1;
    B1 = BFGS_Hessian(grad0, grad1, sk, B0);
    B0 = B1;
    x0 = x1;
    grad0 = grad1;
    alpha0=alpha1;
    fval1 = Function(x1);

%     fprintf('%i           %3g \n', k, fval1)
    if abs(fval1-fval0) < opttol
        break
    end
end
end

