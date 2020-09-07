function [yts] = dyn_fac_forecast(Xt, storeBeta, storeOm, storeFt, storeGamma, InfoCell)

h = size(Xt,1);
lags = size(storeGamma,2);
[K,nFactors, S] = size(storeOm);
[Identities, ~, ~] = MakeObsModelIdentity( InfoCell);

T = size(storeFt,2);
Tout = h/K;
yts = zeros(K,Tout,S);
select = 1:K;
SurX = surForm(Xt,K);
M = storeFt(:, T-lags+1:end,:);
M(:,:,1)
for t = 1:Tout
    ft = zeros(nFactors,S);
    rows = select + K*(t-1);
    for s = 1:S
        for n = 1:nFactors
            ft(n,s) = storeGamma(n,:,s)*M(n,:, s)' + normrnd(0,1,1,1);
        end

        b = storeBeta(:,s);
        Astate = makeStateObsModel(storeOm(:,:,s), Identities, 0);
        d = diag(Astate*Astate' + eye(K)).^(-.5);
        
        yts(:,t,s) = reshape(SurX(rows,:)*b(:), K,1) + Astate*ft(:,s) +chol(diag(d),'lower')*normrnd(0,1,K,1);

    end
    
    z = [reshape(ft, nFactors, 1, S), M];
    M = z(:, 1:end-1,:);
    
end

end

