function [updatedworldobsmod, Sworldpre] = kowUpdateWorldObsModel(...
    ydemut, obsEqnPrecision,worldobsmodel,WorldAr, options,...
    WorldObsModelPriorPrecision, WorldObsModelPriorlogdet, blocks,Eqns,....
    T, oldHessian)
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

[~,p] = chol(Hessian);
if p ~= 0
    fprintf('Non-pd Hessian, using last pd value\n')
    Hessian = oldHessian(:,:,1);
else
    fprintf('Maximization resulted in pd Hessian, saving...\n')
    oldHessian(:,:,1) = Hessian;
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
    [~,p] = chol(Hessian);
    if p ~= 0
        fprintf('Non-pd Hessian, using last pd value\n')
        Hessian = oldHessian(:,:,b);
    else
        fprintf('Maximization resulted in pd Hessian, saving...\n')
        oldHessian(:,:,b) = Hessian;
    end
    iHessian = Hessian\eye(size(Hessian,1));
    updatedworldobsmod(selectC) = kowMhUR(obsslice,themean,iHessian,yslice(:), Sworldpre,pslice,...
            WorldObsModelPriorPrecision, WorldObsModelPriorlogdet, eqnspblock, T);

end

end

