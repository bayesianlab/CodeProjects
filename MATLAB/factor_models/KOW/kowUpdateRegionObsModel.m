function [updatedobsmod, oldmean, oldHessian] = kowUpdateRegionObsModel(ydemut,...
    obsEqnPrecision,regionobsmodel, RegionAr, Countries,...
    SeriesPerCountry,  CountryObsModelPriorPrecision,...
    CountryObsModelPriorlogdet, regionIndices, oldmean, oldHessian,...
    iterationCount)
T = size(ydemut,2);

if iterationCount == 1
    stopTryingFlag = 0;
    options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
        'Display', 'off');
else
    stopTryingFlag = 1;
    options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
    'MaxIterations', 30, 'OptimalityTolerance',.5, 'Display', 'off');
end
fprintf('Region...\n')
updatedobsmod = zeros(SeriesPerCountry*T, 1);
t = 1:SeriesPerCountry;
regioncount = 1;
regioncheck = 0;
for c = 1:Countries
    selectC = t + (c-1)*SeriesPerCountry;
    obsslice = regionobsmodel(selectC);
    yslice = ydemut(selectC, :);
    pslice = obsEqnPrecision(selectC, :);
    if c == regionIndices(regioncount) 
        regioncount = regioncount + 1;
        regioncheck = regioncheck + 1;
        [Sregionpre] = kowMakePrecision(RegionAr(regioncheck,:), 1, T);
        loglike = @(rg) -kowLL(rg, yslice(:),...
            Sregionpre, pslice); 
        [themean, ~,~,~,~, Hessian] = fminunc(loglike, normrnd(0,1,length(obsslice),1), options);
        [~,notpd] = chol(Hessian);
        limit = 0;
        if stopTryingFlag == 0
            while (notpd > 0 ) && (limit < 2)
                limit = limit + 1;
                fprintf('  Trying different point..\n')
                [themean, ~,~,~,~, Hessian] = fminunc(loglike, obsslice +...
                    normrnd(0,2,length(obsslice),1), options);

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
        iHessian = Hessian\eye(size(Hessian,1));
        updatedobsmod(selectC) = kowMhRestricted(obsslice,themean,...
            iHessian, Hessian,yslice(:), Sregionpre,pslice,...
            CountryObsModelPriorPrecision, CountryObsModelPriorlogdet);
    else
        [Sregionpre] = kowMakePrecision(RegionAr(regioncheck,:), 1, T);
        loglike = @(rg) -kowLL(rg, yslice(:),...
        Sregionpre, pslice); 
        [themean, ~,~,~,~, Hessian] = fminunc(loglike, normrnd(0,1,...
            SeriesPerCountry,1), options);
        [~,notpd] = chol(Hessian);
        limit = 0;
        if stopTryingFlag == 0
            while ( notpd > 0 ) && (limit < 2)
                limit = limit + 1;
                fprintf('  Trying different point..\n')
                [themean, ~,~,~,~, Hessian] = fminunc(loglike,...
                    normrnd(0,1,length(obsslice),1), options);
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
        iHessian = Hessian\eye(size(Hessian,1));
        updatedobsmod(selectC) = kowMhUR(obsslice,themean,iHessian,...
            yslice(:), Sregionpre,pslice, CountryObsModelPriorPrecision,...
            CountryObsModelPriorlogdet);
    end   
end
fprintf('Finsihed region obs model updates.\n')
end

