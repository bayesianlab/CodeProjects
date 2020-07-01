function [astar] = zooma(alo, ahi, lam0, lam1, dflam0, dflam1, flam0, flam1, phi,dphi)

dphi0 = dphi(0);
c2 = .9;
c1 = 1e-4;
while 1
    aj = nextlambda( lam0, lam1, dflam0, dflam1, flam0, flam1 );
    phiaj = phi(aj);
    if phiaj > phi(0) + c1*aj*dphi0 | phiaj > phi(alo)
        ahi = aj;
    else
        dphiaj = dphi(aj);

        if abs(dphiaj) < -c2*dphi0
            astar = aj;
            break
        end
        if dphiaj*(ahi-alo) > 0 
            ahi = alo;
        end
        alo = aj;
end
end

