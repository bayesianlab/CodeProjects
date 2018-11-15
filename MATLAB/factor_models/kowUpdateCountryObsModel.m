function [updatedCountryObsModel] = kowUpdateCountryObsModel(ydemut,...
    obsEqnPrecision, countryObsModel, CountryAr, Countries,...
    SeriesPerCountry, options, CountryObsModelPriorPrecision,...
    CountryObsModelPriorlogdet,T, oldHessian)

updatedCountryObsModel = zeros(Countries*SeriesPerCountry,1);
t = 1:SeriesPerCountry;
countryEye = eye(SeriesPerCountry);
for c= 1 :Countries
    selcoun = t + (c-1)*SeriesPerCountry;
    ycslice = ydemut(selcoun, :);
    obsPrecisionSlice = obsEqnPrecision(selcoun);
    obsslice = countryObsModel(selcoun);
    [Scountryprecision] = kowMakeVariance(CountryAr(c,:), 1, T);
    cloglike = @(cg) -kowLL(cg, ycslice(:),Scountryprecision,...
        obsPrecisionSlice, SeriesPerCountry, T);
    [themean, ~,~,~,~, Hessian] = fminunc(cloglike, countryObsModel(selcoun),...
        options);
    [~,p] = chol(Hessian);
    if p ~= 0
        Hessian = oldHessian(:,:,c);
    else
        oldHessian(:,:,c) = Hessian;
    end
    iHessian = Hessian \countryEye;
    updatedCountryObsModel(selcoun)=kowMhRestricted(obsslice, themean,...
        iHessian, Hessian, ycslice(:),...
        Scountryprecision, obsPrecisionSlice, CountryObsModelPriorPrecision, ...
        CountryObsModelPriorlogdet, T);
end
end

