function [updatedworldobsmod, Sworldpre] = kowUpdateWorldObsModel(ydemut, obsEqnVariances,worldobsmodel,...
    WorldAr, options,WorldObsModelPriorPrecision,...
    WorldObsModelPriorlogdet, blocks,Eqns, T)

updatedworldobsmod = zeros(Eqns,1);
eqnspblock = Eqns/blocks;


t = 1:eqnspblock;
yslice = ydemut(t, :);
obsslice = worldobsmodel(t);
pslice = 1./obsEqnVariances(t);
[Sworldpre] = kowMakeVariance(WorldAr(1,:), 1, T);
loglike = @(rg) -kowLL(rg, yslice(:),...
        Sworldpre, pslice, eqnspblock,T);
    
[themean, ~,~,~,~, Hessian] = fminunc(loglike, obsslice, options);
iHessian = Hessian\eye(size(Hessian,1));

updatedworldobsmod(t) = kowMhRestricted(obsslice,themean,iHessian, Hessian,yslice(:), Sworldpre,pslice,...
            WorldObsModelPriorPrecision, WorldObsModelPriorlogdet, eqnspblock, T);
 
for b = 2:blocks
    selectC = t + (b-1)*eqnspblock;
    obsslice = worldobsmodel(selectC);
    yslice = ydemut(selectC, :);
    pslice = 1./obsEqnVariances(selectC);
    [Sregionpre] = kowMakeVariance(WorldAr(1,:), 1, T);
    loglike = @(rg) -kowLL(rg, yslice(:),...
    Sregionpre, pslice, eqnspblock,T); 
    [themean, ~,~,~,~, Hessian] = fminunc(loglike, obsslice, options);
    iHessian = Hessian\eye(size(Hessian,1));
    updatedworldobsmod(selectC) = kowMhUR(obsslice,themean,iHessian,yslice(:), Sworldpre,pslice,...
            WorldObsModelPriorPrecision, WorldObsModelPriorlogdet, eqnspblock, T);

end

end

