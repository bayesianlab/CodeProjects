function [ ArParams, P0 ] = kowArPropose(gammahat, G)

lags = length(gammahat);

keepproposing = 1;
c = 0;
while keepproposing > 0
    c = c + 1;
    ArParams = mvnrnd(gammahat, G);
    bottom = [eye(lags-1),zeros(lags-1,1)];
    Phi = [ArParams;bottom];
    valid = sum(eig(Phi) < 1);
    if valid == lags
        R = [1;zeros(lags-1,1)];
        RRp = R*R';
        ImGamma = eye(lags^2) - kron(Phi,Phi);
        P0 = reshape(ImGamma\RRp(:), lags,lags);
        [~, pd] = chol(P0);
        if pd == 0
            keepproposing = -1;
        end 
    end
end
end

