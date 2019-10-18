function [ proposal, P0, P0old, gammahat, G ] = kowArPropose(y,x, OldAr, sigma2)
Arp = size(OldAr,1);

P0old = sigma2/(1-OldAr^2);

G = ((eye(Arp).*.1) +  (x*x')./sigma2 )\eye(Arp);
gammahat = G* ((x*y')./sigma2);
valid = -1;
c = 0;
if Arp == 1
    proposal = 10;
    while abs(proposal) > 1 & (c ~= 100)
        c = c + 1;
        proposal = tnormrnd(-1,1,gammahat, G);
%         proposal = normrnd(gammahat,G,1,1);
        P0 = sigma2/(1-proposal^2);
    end
    if c == 100
        proposal = OldAr;
        P0 = P0old;
    end
else
    Phi = [OldAr;bottom];
    R = [1;zeros(Arp-1,1)];
    RRp = R*R';
    P0old = reshape((eyelagsquared  - kron(Phi,Phi))\RRp(:), Arp,Arp);
    while valid ~=Arp
        proposal = mvnrnd(gammahat, G);
        Phi = [OldAr;bottom]; 
        valid = sum(eig(Phi) < 1);
        if valid == Arp
            ImGamma = eyelagsquared  - kron(Phi,Phi);
            P0 = reshape(ImGamma\RRp(:), Arp,Arp);
        end
    end
end
 



