function [storePDFVals] = kowObsModelReducedRunCountry(reducedRuns, ydemut,...
    obsEqnPrecision, thetastar, oldMean,oldHessian, CountryAr, blocks,...
    PriorPre, logdetPriorPre)
% Reduced run matrix expected to have draws fill by rows. 
df = 15;
[Eqns, T] = size(ydemut);
[~, rrcols] = size(reducedRuns);
numeratorterm = zeros(rrcols,1);
denominatorterm = zeros(rrcols,1);
eqnspblock = Eqns/blocks;
eyeeqns =  eye(eqnspblock);
storePDFVals = zeros(blocks,1);
t = 1:eqnspblock;

for c = 1:blocks
    selectC = t + (c-1)*eqnspblock;
    yslice = ydemut(selectC, :);
    pslice = obsEqnPrecision(selectC);
    blockb = reducedRuns(selectC,:,:);
    thetastarb = thetastar(selectC);
    thetaMean = oldMean(:,c);
    Precision = oldHessian(:,:,c);
    thetaVariance = eyeeqns/Precision;
    [StatePrecision] = kowStatePrecision(CountryAr(c,:), 1, T);        
    for r = 1:rrcols
        thetag = blockb(:,r);
        % Draw new value based on ordinate for denominator alpha
        w1 = sqrt(chi2rnd(df,1)/df);
        sigma = sqrt(thetaVariance(1,1));
        restricteddraw = thetaMean(1) + truncNormalRand(0, Inf,0, sigma)/w1;
        [cdraw,~,~] = kowConditionalDraw(thetaMean(2:end),...
            Precision(2:end,2:end), Precision(2:end, 1), Precision(1,1), restricteddraw,...
            thetaMean(1), df, df+1);

        candidate = [restricteddraw;cdraw];
        llhoodnum= kowLL(candidate, yslice(:), StatePrecision, pslice);
        Like = llhoodnum + kowEvalPriorsForObsModel(candidate, PriorPre, ...
            logdetPriorPre);
        Prop = mvstudenttpdf(thetastarb, thetaMean, thetaVariance, df);
        Num = Like + Prop ;
        llhoodden= kowLL(thetastarb, yslice(:), StatePrecision, pslice);
        Like = llhoodden + kowEvalPriorsForObsModel(thetastarb, PriorPre, ...
            logdetPriorPre);
        Prop = mvstudenttpdf(candidate, thetaMean, thetaVariance, df);
        Den = Like + Prop;
        alpha = Num - Den;
        denominatorterm(r) = alpha;

        % Numerator value
        llhoodnum= kowLL(thetastarb, yslice(:), StatePrecision, pslice);
        Like = llhoodnum + kowEvalPriorsForObsModel(thetastarb, PriorPre, ...
            logdetPriorPre);
        PropN = mvstudenttpdf(thetag, thetaMean, thetaVariance, df);
        Num = Like + PropN ;
        llhoodden= kowLL(thetag, yslice(:), StatePrecision, pslice);
        Like = llhoodden + kowEvalPriorsForObsModel(thetag, PriorPre, ...
            logdetPriorPre);
        PropD = mvstudenttpdf(thetastarb, thetaMean, thetaVariance, df);
        Den = Like + PropD;
        alphagtostar = min(0,Num - Den);
        numeratorterm(r) = alphagtostar + PropD;
    end
    storePDFVals(c) = logAvg(numeratorterm') - logAvg(denominatorterm');
end
    
end


