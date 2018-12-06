function [ proposal, P0, P0old, gammaHat, G ] = kowArPropose(y,x, OldAr)
Arp = size(x,1);
G = ((eye(Arp).*.01) +  x*x')\eye(Arp);
gammahat = G*x*y';
lags = length(gammahat);
keepproposing = 1;
c = 0;
R = [1;zeros(lags-1,1)];
RRp = R*R';
eyelagsquared = eye(lags^2);
bottom = [eye(lags-1),zeros(lags-1,1)];
Phi = [OldAr;bottom]; 
P0old = reshape((eyelagsquared  - kron(Phi,Phi))\RRp(:), lags,lags);

while keepproposing > 0
    c = c + 1;
    if c == 20
        proposal = zeros(1,Arp);
        P0 = eye(Arp);
        keepproposing = -1;
    else
        proposal = mvnrnd(gammahat, G);
        bottom = [eye(lags-1),zeros(lags-1,1)];
        Phi = [proposal;bottom];
        valid = sum(eig(Phi) < 1);
        if valid == lags
            ImGamma = eyelagsquared  - kron(Phi,Phi);
            P0 = reshape(ImGamma\RRp(:), lags,lags);
            [~, pd] = chol(P0);
            if pd == 0
                keepproposing = -1;
            end 
        end
    end
end
end

