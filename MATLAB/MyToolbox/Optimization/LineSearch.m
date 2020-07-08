function [astar] = LineSearch(alpha0, alpha1, Phi, DPhi)
c1 = 1e-4;
c2 = .9;
z=0;
wolfe1 = 0;
while z <= 1
    z = z+1;
    phia1 = Phi(alpha1);
    phi0 = Phi(0);
    DPhi0 = DPhi(alpha0);
    cond1 = (phi0 + c1.*alpha1.*DPhi0);
    
    if phia1 > cond1
        q = 0;
        while wolfe1 == 0 && q < 2
            q=q+1;
            alpha2 = -(DPhi0* (alpha1^2) )/ (2* ( phia1 - phi0 - DPhi0*alpha1));
            cond1 = (phi0 + c1.*alpha2.*DPhi0);
            phia1 = Phi(alpha2);
            if phia1 < cond1
                wolfe1 = 1;
                astar = alpha1;
            end
            alpha1 = alpha2;
        end
    end
    
%     if ((phia1 > phia0) || (phia1 > cond1)) 
%         fprintf('zoom1\n')
%         astar = zooma(alpha0, alpha1, Phi, DPhi, phi0, DPhi0);
%         return
%     end
%     DPhiA1 = DPhi(alpha1);
%     if abs(DPhiA1 ) < -c2*DPhi0
%         astar = alpha1;
%         return
%     end
%     if DPhiA1 > 0
%         fprintf('zoom2\n')
%         astar = zooma(alpha1, alpha0, Phi, DPhi, phi0, DPhi0);
%         return
%     end
    alpha1 = 2*alpha1;
end
end

