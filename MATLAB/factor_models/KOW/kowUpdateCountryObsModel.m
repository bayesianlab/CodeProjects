function [updatedCountryObsModel] = kowUpdateCountryObsModel(ydemut,...
    obsEqnPrecision, countryObsModel, CountryAr, Countries,...
    SeriesPerCountry, CountryObsModelPriorPrecision,...
    CountryObsModelPriorlogdet,T, oldHessian, iterationCount)
if iterationCount == 1
    stopTryingFlag = 0;
    options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
        'Display', 'off');
else
    stopTryingFlag = 1;
    options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
    'MaxIterations', 3, 'Display', 'off');
end
updatedCountryObsModel = zeros(Countries*SeriesPerCountry,1);
t = 1:SeriesPerCountry;
countryEye = eye(SeriesPerCountry);
for c= 1 :Countries
    selcoun = t + (c-1)*SeriesPerCountry;
    ycslice = ydemut(selcoun, :);
    obsPrecisionSlice = obsEqnPrecision(selcoun);
    obsslice = countryObsModel(selcoun);
    [Scountryprecision] = kowMakeVariance(CountryAr(c,:), 1, T);
    loglike = @(cg) -kowLL(cg, ycslice(:),Scountryprecision,...
        obsPrecisionSlice, SeriesPerCountry, T);
    [themean, ~,~,~,~, Hessian] = fminunc(loglike, countryObsModel(selcoun),...
        options);
    notvalid = ~isfinite(sum(sum(Hessian)));
    negativediag = sum(diag(Hessian) < 0);
    [~,notpd] = chol(Hessian);
    limit = 0;
        if stopTryingFlag == 0
            while (notvalid == 1 || negativediag > 0 || notpd > 0 ) && limit < 2
                limit = limit + 1;
                fprintf('  Trying different point..\n')
                [themean, ~,~,~,~, Hessian] = fminunc(loglike, obsslice +...
                    normrnd(0,2,length(obsslice),1), options);
                notvalid = ~isfinite(sum(sum(Hessian)));
                negativediag = sum(diag(Hessian) < 0);
                [~,notpd] = chol(Hessian);
            end
            if limit == 2 
                fprintf('Non-pd Hessian, using last pd value\n')
                Hessian = oldHessian(:,:,c);
            else
                fprintf('Maximization resulted in pd Hessian, saving...\n')
                oldHessian(:,:,c) = Hessian;
            end
        else
            if notpd ~= 0
                fprintf('Non-pd Hessian, using last pd value\n')
                Hessian = oldHessian(:,:,c);
            else
                fprintf('Maximization resulted in pd Hessian, saving...\n')
                oldHessian(:,:,c) = Hessian;
            end
        end
    iHessian = Hessian \countryEye;
    updatedCountryObsModel(selcoun)=kowMhRestricted(obsslice, themean,...
        iHessian, Hessian, ycslice(:),...
        Scountryprecision, obsPrecisionSlice, CountryObsModelPriorPrecision, ...
        CountryObsModelPriorlogdet, T);
end
fprintf('Finished country  obs model updates.\n')
end

