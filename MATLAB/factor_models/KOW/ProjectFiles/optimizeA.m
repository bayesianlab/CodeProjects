function [xt, lastMean, lastHessian] = ...
    optimizeA(x0, ydemut, obsPrecision, factor, stateTransitions,...
    backup, RestrictionLevel, Regions, IRegion, ICountry, options)


df = 20;
[K,T] = size(ydemut);
[R, C] = size(x0);
xt = zeros(R,C);
lmindex = 1;
nFactors = size(factor,1);


for i = 1:3
    
    nx = x0(:,i);
    factorPrecision = kowStatePrecision(stateTransitions(i), 1, T);
    subFt = factor(i,:);
    tempSOM = x0;
    if i == 1
        tempSOM(:,1) = 0;
    elseif i == 2
        tempSOM(:,2) = 0;
    else
        tempSOM(:,3) = 0;
    end
    tempSOM
    tempy = ydemut - tempSOM*factor;

    if RestrictionLevel == 1
        if i > 2
            lastMean = backup{lmindex};
            lastHessian = backup{lmindex+1};
            lastMean = backup{lmindex};
            lastHessian = backup{lmindex+1};
            xt(:,i) = restrictedDraw(nx, tempy, obsPrecision, subFt,...
                factorPrecision, K, lastMean, lastHessian, options);
        else
            lastMean = backup{lmindex};
            lastHessian = backup{lmindex+1};
            xt(:,i) = unrestrictedDraw(nx, yt, obsPrecision, subFt, factorPrecision,...
                K, lastMean, lastHessian, options)
        end
    elseif RestrictionLevel == 2
        if i > 1
            lastMean = backup{lmindex};
            lastHessian = backup{lmindex+1};
            xt(:,i) = restrictedDraw(nx, tempy, obsPrecision, subFt,...
                factorPrecision, K, lastMean, lastHessian, options);
        else
            lastMean = backup{lmindex};
            lastHessian = backup{lmindex+1};
            xt(:,i) = unrestrictedDraw(nx, yt, obsPrecision, subFt, factorPrecision,...
                K, lastMean, lastHessian, options)
        end
        
    elseif RestrictionLevel == 3
        lastMean = backup{lmindex};
        lastHessian = backup{lmindex+1};
        xt(:,i) = restrictedDraw(nx, tempy, obsPrecision, subFt,...
            factorPrecision, K, lastMean, lastHessian, options);
%         kowUpdateLatent(tempy(:), xt(:,i), factorPrecision, obsPrecision)
    else
        error('Restriction level must be 1-3')
    end
    lmindex = lmindex + 2; 
end
end

