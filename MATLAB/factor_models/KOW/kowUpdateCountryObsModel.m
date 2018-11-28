function [updatedCountryObsModel, oldmean, oldHessian] = kowUpdateCountryObsModel(ydemut,...
    obsEqnPrecision, countryObsModel, CountryAr, Countries,...
    SeriesPerCountry, CountryObsModelPriorPrecision,...
    CountryObsModelPriorlogdet,  oldmean, oldHessian, iterationCount)
fprintf('Country\n')
T = size(ydemut,2);
if iterationCount == 1
    stopTryingFlag = 0;
    options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
        'Display', 'off');
else
    stopTryingFlag = 1;
    options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
    'MaxIterations', 30, 'OptimalityTolerance', .5, 'Display', 'off');
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
    [~,notpd] = chol(Hessian);
    limit = 0;
        if stopTryingFlag == 0
            while (notpd > 0 ) && (limit < 2)
                limit = limit + 1;
                fprintf('  Initial point failed, Trying different point...\n')
                [themean, ~,~,~,~, Hessian] = fminunc(loglike, normrnd(0,1,...
                    SeriesPerCountry,1), options);
                [~,notpd] = chol(Hessian);
            end
            if limit == 2 
                fprintf('%i Non-pd Hessian, using last pd value\n', c)
                themean = oldmean(:,c);
                Hessian = oldHessian(:,:,c);
            else
                fprintf('%i Maximization resulted in pd Hessian, saving...\n', c)
                oldmean(:,c) = themean;
                oldHessian(:,:,c) = Hessian;
            end
        else
            if notpd ~= 0
                fprintf('%i Non-pd Hessian, using last pd value\n', c)
                themean = oldmean(:,c);
                Hessian = oldHessian(:,:,c);
            else
                fprintf('%i Maximization resulted in pd Hessian, saving...\n', c)
                oldmean(:,c) = themean;
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

