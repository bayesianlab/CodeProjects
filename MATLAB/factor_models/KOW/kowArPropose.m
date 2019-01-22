function [ proposal, P0, P0old, gammahat, G ] = kowArPropose(y,x, OldAr)
Arp = size(x,1);
G = ((eye(Arp).*.01) +  x*x')\eye(Arp);
gammahat = G*((eye(Arp)*ones(Arp,1).*.01) +  x*y');
keepproposing = 1;
c = 0;
R = [1;zeros(Arp-1,1)];
RRp = R*R';
eyelagsquared = eye(Arp^2);
bottom = [eye(Arp-1),zeros(Arp-1,1)];
Phi = [OldAr;bottom]; 
P0old = reshape((eyelagsquared  - kron(Phi,Phi))\RRp(:), Arp,Arp);
while keepproposing > 0
    c = c + 1;
    if c == 20
        proposal = zeros(1,Arp);
        P0 = eye(Arp);
        keepproposing = -1;
    else
        proposal = mvnrnd(gammahat, G);
        bottom = [eye(Arp-1),zeros(Arp-1,1)];
        Phi = [proposal;bottom];
        valid = sum(eig(Phi) < 1);
        if valid == Arp
            ImGamma = eyelagsquared  - kron(Phi,Phi);
            P0 = reshape(ImGamma\RRp(:), Arp,Arp);
            [~, pd] = chol(P0);
            if pd == 0
                keepproposing = -1;
            end 
        end
    end
end
end

