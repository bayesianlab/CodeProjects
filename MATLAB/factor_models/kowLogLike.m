function [ ll ] = kowLogLike( demeanedy, ObsModel, ObsModelVariances,Sworld,...
    Sregion, Scountry )
K = 3;
T = size(demeanedy,1);
constant = K*T*log(2*pi);
worlddiag = diag(Sworld);
regiondiag = diag(Sregion);
countrydiag = diag(Scountry);
ll=0;
for t = 1:T
    V = ObsModelVariances + (ObsModel(1)^2)*worlddiag(t) + ...
            (ObsModel(2)^2)*regiondiag(t) + ...
            (ObsModel(3)^2)*countrydiag(t);

    ll = ll + -.5*(constant + log(V) + (demeanedy(t)^2)*(1/V));
end
end

