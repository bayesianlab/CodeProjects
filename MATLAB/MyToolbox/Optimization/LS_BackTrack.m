function [astar] = LS_BackTrack(alpha0, Phi, DPhi)
c1 = 1e-4;
DPhi0 = DPhi(0);
Phi0 = Phi(0);
failed = 0;
wolfe1=0;
while (failed <= 10) && (wolfe1 == 0)
    failed = failed + 1;
    phia0 = Phi(alpha0);
    cond1 = (Phi0 + c1.*alpha0.*DPhi0);
    if phia0 > cond1
        alpha1 = -(DPhi0* (alpha0^2) )/ (2* ( phia0 - Phi0 - DPhi0*alpha0));
        alpha0 = alpha1;
    else
        wolfe1=1;
        astar = alpha0;
    end
end
if wolfe1 == 0
    fprintf('using grid\n')
    alphas = linspace(0,alpha0, 50);
    storeVals = zeros(1,50);
    for i = 1:50
        storeVals(i) = Phi(alphas(i));
    end
    [~, dx] = min(storeVals);
    astar = alphas(dx);
end

end

