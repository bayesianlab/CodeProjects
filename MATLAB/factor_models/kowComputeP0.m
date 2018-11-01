function [P0, PHI] = kowComputeP0(stackedTransitions)
[K,Arp] = size(stackedTransitions);
Phi = zeros(Arp*K, Arp);
t = 1:Arp;
for i = 1:K
    select = t + (i-1)*Arp;
    Phi(select,:) = [stackedTransitions(i,:); eye(Arp-1), zeros(Arp-1,1)];
end
PHI = sparse(kron(eye(K), ones(Arp,Arp)).*repmat(Phi,1,K));
R = repmat([1;0;0], K,1);
RRp = R*R';
P0 = reshape((speye((K*Arp)^2) - kron(PHI,PHI))\RRp(:), K*Arp,K*Arp);
PHI = PHI(1:3:end,:);
end

