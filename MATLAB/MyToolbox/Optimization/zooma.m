function [astar, nodecrease] = zooma(alo, ahi, Phi, DPhi, Phi0, DPhi0)

c2 = .8;
c1 = 1e-4;
z=0;
nodecrease = 0;
stop0 = 0;
MAX = 10;
while z <= MAX && stop0 == 0
    z= z+1;
    PhiA1 = Phi(ahi);
%     [DPhi0,ahi,PhiA1,Phi0]
    
    aj = -(DPhi0* (ahi^2) )/ (2* ( PhiA1 - Phi0 - DPhi0*ahi))
    if abs(aj - alo) < eps
        astar = alo/2;
        return
    end
    if abs(alo - aj) > 1e10
        astar = alo/2;
        return
    end
    phiaj = Phi(aj);
    cond1 = (Phi0 + c1*aj*DPhi0);
    if (phiaj > cond1) || (phiaj > Phi(alo))
        ahi = aj;
    else
        dphiaj = DPhi(aj);
        if abs(dphiaj) < -c2*DPhi0
            fprintf('RETURNED\n')
            astar = aj;
            return 
        end
        if dphiaj*(ahi-alo) > 0
            ahi = alo;
        end
        alo = aj;
    end
end
end

