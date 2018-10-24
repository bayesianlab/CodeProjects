function [ dll, hess ] = kowll( demeanedy, variance, ObsModel, Sworld, Sregion, Scountry, h )
K = 3;
T = size(demeanedy,1);
outerprod = zeros(K,K);
keepscore = zeros(K,T);
constant = log(2*pi);
worlddiag = diag(Sworld);
regiondiag = diag(Sregion);
countrydiag = diag(Scountry);
temp = ObsModel;

for t = 1:T
    V = variance + (ObsModel(1)^2)*worlddiag(t) + ...
            (ObsModel(2)^2)*regiondiag(t) + ...
            (ObsModel(3)^2)*countrydiag(t);
    ll =    log(mvnpdf(demeanedy(t), 0, V));
    for k = 1:K
        temp(k) = ObsModel(k) + h;
        V = variance + (temp(1)^2)*worlddiag(t) + ...
            (temp(2)^2)*regiondiag(t) + (temp(3)^2)*countrydiag(t);
        llh = log(mvnpdf(demeanedy(t), 0, V));
         keepscore(k) = (ll - llh)/h;
        temp = ObsModel;
    end
    outerprod = outerprod + keepscore*keepscore';
end
dll = mean(keepscore,2);
hess=outerprod./T;
end

