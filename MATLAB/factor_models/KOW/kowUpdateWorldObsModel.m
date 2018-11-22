function [updatedworldobsmod, Sworldpre] = kowUpdateWorldObsModel(...
    ydemut, obsEqnPrecision,worldobsmodel,WorldAr,...
    WorldObsModelPriorPrecision, WorldObsModelPriorlogdet, blocks,Eqns,....
    T, oldHessian, iterationCount)
if iterationCount == 1
    stopTryingFlag = 0;
    options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
        'Display', 'off');
else
    stopTryingFlag = 1;
    options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
    'MaxIterations', 3, 'Display', 'off');
end
    
fprintf('World...\n')
updatedworldobsmod = zeros(Eqns,1);
eqnspblock = Eqns/blocks;


t = 1:eqnspblock;
yslice = ydemut(t, :);
obsslice = worldobsmodel(t);
pslice = obsEqnPrecision(t);
[Sworldpre] = kowMakeVariance(WorldAr(1,:), 1, T);
loglike = @(rg) -kowLL(rg, yslice(:),...
        Sworldpre, pslice, eqnspblock,T);
    
[themean, ~,~,~,~, Hessian] = fminunc(loglike, obsslice, options);
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
        Hessian = oldHessian(:,:,1);
    else
        fprintf('Maximization resulted in pd Hessian, saving...\n')
        oldHessian(:,:,1) = Hessian;
    end
else
    if notpd ~= 0
        fprintf('Non-pd Hessian, using last pd value\n')
        Hessian = oldHessian(:,:,1);
    else
        fprintf('Maximization resulted in pd Hessian, saving...\n')
        oldHessian(:,:,1) = Hessian;
    end
end
iHessian = Hessian\eye(size(Hessian,1));
updatedworldobsmod(t) = kowMhRestricted(obsslice,themean,iHessian,...
    Hessian,yslice(:), Sworldpre,pslice, WorldObsModelPriorPrecision,...
    WorldObsModelPriorlogdet,  T);
 
for b = 2:blocks
    selectC = t + (b-1)*eqnspblock;
    obsslice = worldobsmodel(selectC);
    yslice = ydemut(selectC, :);
    pslice = obsEqnPrecision(selectC);
    [Sregionpre] = kowMakeVariance(WorldAr(1,:), 1, T);
    loglike = @(rg) -kowLL(rg, yslice(:),...
    Sregionpre, pslice, eqnspblock,T); 
    [themean, ~,~,~,~, Hessian] = fminunc(loglike, obsslice, options);
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
            Hessian = oldHessian(:,:,b);
        else
            fprintf('Maximization resulted in pd Hessian, saving...\n')
            oldHessian(:,:,b) = Hessian;
        end
    else
        if notpd ~= 0
            fprintf('Non-pd Hessian, using last pd value\n')
            Hessian = oldHessian(:,:,b);
        else
            fprintf('Maximization resulted in pd Hessian, saving...\n')
            oldHessian(:,:,b) = Hessian;
        end
    end
    iHessian = Hessian\eye(size(Hessian,1));
    updatedworldobsmod(selectC) = kowMhUR(obsslice,themean,iHessian,yslice(:), Sworldpre,pslice,...
            WorldObsModelPriorPrecision, WorldObsModelPriorlogdet, eqnspblock, T);

end

end

