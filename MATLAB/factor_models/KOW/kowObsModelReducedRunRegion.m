function [storePDFVals] = kowObsModelReducedRunRegion(reducedRuns, ydemut,...
    obsEqnPrecision, thetastar, oldMean,oldHessian, RegionAr, blocks, Eqns,...
    PriorPre, logdetPriorPre,  regionIndices)
df = 15;
[~,T] = size(ydemut);
[rrrows, rrcols] = size(reducedRuns);
numeratorterm = zeros(rrcols,1);
denominatorterm = zeros(rrcols,1);
eqnspblock = Eqns/blocks;
eyeeqns =  eye(eqnspblock);
storePDFVals = zeros(blocks,1);
t = 1:eqnspblock;
regioncount = 1;
regioncheck = 0;
for c = 1:blocks
    selectC = t + (c-1)*eqnspblock;
    yslice = ydemut(selectC, :);
    pslice = obsEqnPrecision(selectC);
    blockb = squeeze(reducedRuns(selectC,:,:));
    thetastarb = thetastar(selectC);
    thetaMean = oldMean(:,c);
    Precision = oldHessian(:,:,c);
    thetaVariance = eyeeqns/Precision;

    for r = 1:rrcols
        if c == regionIndices(regioncount) 
            regioncount = regioncount + 1;
            regioncheck = regioncheck + 1;
            [StatePrecision] = kowStatePrecision(RegionAr(regioncheck,:), 1, T);        
            thetag = blockb(:,r);
            % Draw new value based on ordinate for denominator alpha
            w1 = sqrt(chi2rnd(df,1)/df);
            sigma = sqrt(thetaVariance(1,1));
            restricteddraw = thetaMean(1) + truncNormalRand(0, Inf,0, sigma)/w1;
            [cdraw,~,~] = kowConditionalDraw(thetaMean(2:end),...
                Precision(2:end,2:end), Precision(2:end, 1), Precision(1,1), restricteddraw,...
                thetaMean(1), df, df+1);
            candidate = [restricteddraw;cdraw];
            llhoodnum= kowLL(candidate, yslice(:), StatePrecision,...
                pslice);
            Like = llhoodnum + kowEvalPriorsForObsModel(candidate, PriorPre, ...
                logdetPriorPre);
            Prop = mvstudenttpdf(thetastarb, thetaMean, thetaVariance, df);
            Num = Like + Prop ;
            llhoodden= kowLL(thetastarb, yslice(:), StatePrecision,...
                pslice);
            Like = llhoodden + kowEvalPriorsForObsModel(thetastarb, PriorPre, ...
                logdetPriorPre);
            Prop = mvstudenttpdf(candidate, thetaMean, thetaVariance, df);
            Den = Like + Prop;
            alpha = Num - Den;
            denominatorterm(r) = alpha;
            
            % Numerator value
            llhoodnum= kowLL(thetastarb, yslice(:), StatePrecision,...
                pslice);
            Like = llhoodnum + kowEvalPriorsForObsModel(thetag, PriorPre, ...
                logdetPriorPre);
            PropN = mvstudenttpdf(thetag, thetaMean, thetaVariance, df);
            Num = Like + PropN ;
            
            llhoodden= kowLL(thetag, yslice(:), StatePrecision,...
                pslice);
            Like = llhoodden + kowEvalPriorsForObsModel(thetag, PriorPre, ...
                logdetPriorPre);
            PropD = mvstudenttpdf(thetastarb, thetaMean, thetaVariance, df);
            Den = Like + PropD;
            alphagtostar = min(0,Num - Den);
            numeratorterm(r) = alphagtostar + PropD;
        else
            [StatePrecision] = kowStatePrecision(RegionAr(regioncheck,:), 1, T);
            % Unrestricted cases 
            % Denominator terms
            w1 = sqrt(chi2rnd(df,1)/df);
            sigma = sqrt(thetaVariance(1,1));
            restricteddraw = thetaMean(1)+ truncNormalRand(0, Inf,0, sigma)/w1;
            [cdraw,~,~] = kowConditionalDraw(thetaMean(2:end),...
                Precision(2:end,2:end), Precision(2:end, 1), Precision(1,1), restricteddraw,...
                thetaMean(1), df, df+1);
            candidate = [restricteddraw;cdraw];
            llhoodnum= kowLL(candidate, yslice(:), StatePrecision,...
                pslice);
            Like = llhoodnum + kowEvalPriorsForObsModel(candidate, PriorPre, ...
                logdetPriorPre);
            Prop = mvstudenttpdf(thetastarb, thetaMean, thetaVariance, df);
            Num = Like + Prop ;
            llhoodden= kowLL(thetastarb, yslice(:), StatePrecision,...
                pslice);
            Like = llhoodden + kowEvalPriorsForObsModel(thetastarb, PriorPre, ...
                logdetPriorPre);
            Prop = mvstudenttpdf(candidate, thetaMean, thetaVariance, df);
            Den = Like + Prop;
            alpha = min(0,Num - Den);
            denominatorterm(r) = alpha;

            % Numerator terms
            llhoodnum= kowLL(thetag, yslice(:), StatePrecision,...
                pslice);
            llhoodden= kowLL(thetastarb, yslice(:), StatePrecision,...
                pslice);
            Like = llhoodnum + kowEvalPriorsForObsModel(thetag, PriorPre, ...
                logdetPriorPre);
            PropN = mvstudenttpdf(thetastarb, thetaMean, thetaVariance, df);
            Num = Like + PropN ;
            Like = llhoodden + kowEvalPriorsForObsModel(thetastarb, PriorPre, ...
                logdetPriorPre);
            PropD = mvstudenttpdf(thetag, thetaMean, thetaVariance, df);
            Den = Like + PropD;
            alphagtostar = min(0,Num - Den);
            numeratorterm(r) = alphagtostar + PropD;            
        end 
    end
    storePDFVals(c) = logAvg(numeratorterm') - logAvg(denominatorterm');
end

end

