function [ dll, hess ] = kowll( demeanedy, variance, ObsModel, Sworld, Sregion, Scountry, h )


K = 3;
T = size(demeanedy,1);
outerprod = zeros(K,K);
keepscore = zeros(K,T);
constant = K*T*log(2*pi);
worlddiag = diag(Sworld);
regiondiag = diag(Sregion);
countrydiag = diag(Scountry);


temp = ObsModel;

for t = 1:T
    logvar = log(diag(variance) + (ObsModel(1)^2)*worlddiag(t) + ...
            (ObsModel(2)^2)*regiondiag(t) + (ObsModel(3)^2)*countrydiag(t));
    Vtinv = recursiveWoodbury(variance, ObsModel(1), worlddiag(t), ObsModel(2),...
            regiondiag(t),ObsModel(3), countrydiag(t));
    ll = -.5*(constant + logvar + (demeanedy(t)^2)*Vtinv);
    for k = 1:K
        temp(k) = ObsModel(k) + h;
        logvar = log(diag(variance) + (temp(1)^2)*worlddiag(t) + ...
            (temp(2)^2)*regiondiag(t) + (temp(3)^2)*countrydiag(t));
        Vtinv = recursiveWoodbury(variance, temp(1), worlddiag(t), temp(2),...
            regiondiag(t), temp(3), countrydiag(t));
         llh = -.5*(constant + logvar + (demeanedy(t)^2)*Vtinv);
         keepscore(k) = (ll - llh)/h;
        temp = ObsModel;
    end
    outerprod = outerprod + keepscore*keepscore';
end
dll = mean(keepscore,2);
hess=outerprod./T;
end

