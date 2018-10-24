function [ ll ] = kowLogLike( demeanedy, ObsModel, ObsModelVariances,Sworld,...
    Sregion, Scountry )
T = size(demeanedy,1);
worlddiag = diag(Sworld);
regiondiag = diag(Sregion);
countrydiag = diag(Scountry);
ll=0;
for t = 1:T
    V = ObsModelVariances + (ObsModel(1)^2)*worlddiag(t) + ...
            (ObsModel(2)^2)*regiondiag(t) + ...
            (ObsModel(3)^2)*countrydiag(t);
    ll = ll + log(mvnpdf(demeanedy(t), 0, V));
end
end

