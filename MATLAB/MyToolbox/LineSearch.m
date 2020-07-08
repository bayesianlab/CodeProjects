function [astar] = LineSearch(alpha0, alpha1, Phi, DPhi)
c1 = 1e-4;
c2 = .9;
z=0;
while z <= 1
    z = z+1;
    phia1 = Phi(alpha1);
    phia0 = Phi(alpha0);
    phi0 = Phi(0);
    DPhi0 = DPhi(alpha0);
    cond1 = (phi0 + c1.*alpha1.*DPhi0);
    if ((phia1 > phia0) || (phia1 > cond1)) && DPhi0 < 0
        astar = zooma(alpha0, alpha1, Phi, DPhi, phi0, DPhi0);
        return
    end
    DPhiA1 = DPhi(alpha1);
    if abs(DPhiA1 ) < -c2*DPhi0
        astar = alpha1;
        return
    end
    if DPhiA1 > 0
        astar = zooma(alpha1, alpha0, Phi, DPhi, phi0, DPhi0);
        return
    end
    alpha1 = 2*alpha1;
end
end

