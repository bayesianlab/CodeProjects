function [Precision] = kowStatePrecision(stateTransition, stateVar, T)
Tm1 = T-1;
nFactors = size(stateTransition,1);
TnFactors = T*nFactors;
PhiKronPhi = kron(stateTransition,stateTransition);
InFac = speye(nFactors);
Im = speye(size(PhiKronPhi,1));
vecRQR = InFac*(stateVar.*eye(nFactors))*InFac;
vecRQR = vecRQR(:);
P0 = (Im - PhiKronPhi)\vecRQR;
P0 = reshape(P0, nFactors,nFactors);
P0 = P0\eye(nFactors);
EmptySparse = sparse(nFactors, Tm1*nFactors);
Top = [P0, EmptySparse];
Omega = spdiags(repmat(stateVar,Tm1,1),0, Tm1*nFactors,Tm1*nFactors);
Omega = [Top;EmptySparse', Omega];
H = full(kron(spdiags(ones(T,1),-1, T,T), -stateTransition)) + speye(TnFactors,TnFactors);
Precision = H'*Omega*H ;
end

