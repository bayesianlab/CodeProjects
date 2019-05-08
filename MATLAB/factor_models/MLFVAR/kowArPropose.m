function [ proposal, P0, P0old, gammahat, G ] = kowArPropose(y,x, OldAr)
Arp = size(OldAr,1);



G = ((eye(Arp).*.01) +  x*x')\eye(Arp);
gammahat = G* (x*y');
valid = -1;
c = 0;
if Arp == 1
    proposal = 10;
    while abs(proposal) > 1 & (c < 5)
        c = c + 1;
        proposal = normrnd(gammahat,G,1,1);
        P0 = 1/(1-proposal^2);
        P0old = 1/(1-OldAr^2);
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
 



