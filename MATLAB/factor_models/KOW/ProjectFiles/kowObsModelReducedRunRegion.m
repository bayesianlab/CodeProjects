function [storePDFVals] = kowObsModelReducedRunRegion(reducedRuns, ydemut,...
    obsEqnPrecision, thetastar, oldMean,oldHessian, RegionAr, blocks, Eqns,...
    regionIndices, ObsPriorMean, ObsPriorVar, factor)
df = 15;
[~,T] = size(ydemut);
[rrrows, rrcols] = size(reducedRuns);
numeratorterm = zeros(rrcols,1);
denominatorterm = zeros(rrcols,1);
eqnspblock = Eqns/blocks;
eyeeqns =  eye(eqnspblock);
storePDFVals = zeros(blocks,1);
t = 1:eqnspblock;
n = length(t);
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
            candidate = thetaMean(2:n) + chol(thetaVariance(2:n,2:n), 'lower')*normrnd(0,1, n-1,1)./w1;
            candidate = [restricteddraw;candidate];
            % Denominator value
            Like= -kowRatioLL(yslice, candidate, ...
                    ObsPriorMean(selectC), ObsPriorVar(selectC,selectC), pslice, factor(regioncheck,:), StatePrecision) ;
            Prop = mvstudenttpdf(thetastarb, thetaMean, thetaVariance, df);
            Num = Like + Prop ;
            Like = -kowRatioLL(yslice, thetastarb, ...
                    ObsPriorMean(selectC), ObsPriorVar(selectC,selectC), pslice, factor(regioncheck,:), StatePrecision) ;
            Prop = mvstudenttpdf(candidate, thetaMean, thetaVariance, df);
            Den = Like + Prop;
            alpha = Num - Den;
            denominatorterm(r) = alpha;
            
            % Numerator value
            Like = -kowRatioLL(yslice, thetastarb, ...
                    ObsPriorMean(selectC), ObsPriorVar(selectC,selectC), pslice, factor(regioncheck,:), StatePrecision) ;
            PropN = mvstudenttpdf(thetag, thetaMean, thetaVariance, df);
            Num = Like + PropN ;
            Like = -kowRatioLL(yslice, thetastarb, ...
                    ObsPriorMean(selectC), ObsPriorVar(selectC,selectC), pslice, factor(regioncheck,:), StatePrecision) ;
            PropD = mvstudenttpdf(thetastarb, thetaMean, thetaVariance, df);
            Den = Like + PropD;
            alphagtostar = min(0,Num - Den);
            numeratorterm(r) = alphagtostar + PropD;

        else
            [StatePrecision] = kowStatePrecision(RegionAr(regioncheck,:), 1, T);
            thetag = blockb(:,r);
            % Unrestricted cases 
            % Numerator terms
           LikeN =-kowRatioLL(yslice, thetastarb, ...
                    ObsPriorMean(selectC), ObsPriorVar(selectC,selectC), pslice, factor(regioncheck,:), StatePrecision) ;
            
            LikeD = -kowRatioLL(yslice, thetag, ...
                    ObsPriorMean(selectC), ObsPriorVar(selectC,selectC), pslice, factor(regioncheck,:), StatePrecision) ;
            PropN = mvstudenttpdf(thetag, thetaMean, thetaVariance, df);
            Num = LikeN + PropN ;
            PropD = mvstudenttpdf(thetastarb, thetaMean, thetaVariance, df);
            Den = LikeD + PropD;
            alphagtostar = min(0,Num - Den);
            numeratorterm(r) = alphagtostar + PropD; 
            % Denominator terms
            w1 = sqrt(chi2rnd(df,1)/df);
            candidate = thetaMean + chol(thetaVariance, 'lower')*normrnd(0,1, n,1)./w1;
            % Denominator value
            Like= -kowRatioLL(yslice, candidate, ...
                    ObsPriorMean(selectC), ObsPriorVar(selectC,selectC), pslice, factor(regioncheck,:), StatePrecision) ;
            Prop = mvstudenttpdf(thetastarb, thetaMean, thetaVariance, df);
            Num = Like + Prop ;
            Like = -kowRatioLL(yslice, thetastarb, ...
                    ObsPriorMean(selectC), ObsPriorVar(selectC,selectC), pslice, factor(regioncheck,:), StatePrecision) ;
            Prop = mvstudenttpdf(candidate, thetaMean, thetaVariance, df);
            Den = Like + Prop;
            alpha = Num - Den;
            denominatorterm(r) = alpha;        
        end 
    end

    storePDFVals(c) = logAvg(numeratorterm') - logAvg(denominatorterm');
end
end

