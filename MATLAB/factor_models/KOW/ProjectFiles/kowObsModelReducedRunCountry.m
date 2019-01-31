function [storePDFVals] = kowObsModelReducedRunCountry(reducedRuns, ydemut,...
    obsEqnPrecision, thetastar, oldMean,oldHessian, CountryAr, blocks,...
    ObsPriorMean, ObsPriorVar, factor)
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
n = length(t);
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
            candidate = thetaMean(2:n) + chol(thetaVariance(2:n,2:n), 'lower')*normrnd(0,1, n-1,1)./w1;
            candidate = [restricteddraw;candidate];
        % Denominator value
        Like= -kowRatioLL(yslice, candidate, ...
                ObsPriorMean(selectC), ObsPriorVar(selectC,selectC), pslice, factor(c,:), StatePrecision) ;
        Prop = mvstudenttpdf(thetastarb, thetaMean, thetaVariance, df);
        Num = Like + Prop ;
        Like = -kowRatioLL(yslice, thetastarb, ...
                ObsPriorMean(selectC), ObsPriorVar(selectC,selectC), pslice, factor(c,:), StatePrecision) ;
        Prop = mvstudenttpdf(candidate, thetaMean, thetaVariance, df);
        Den = Like + Prop;
        alpha = Num - Den;
        denominatorterm(r) = alpha;

        % Numerator value
        Like = -kowRatioLL(yslice, thetastarb, ...
                ObsPriorMean(selectC), ObsPriorVar(selectC,selectC), pslice, factor(c,:), StatePrecision) ;
        PropN = mvstudenttpdf(thetag, thetaMean, thetaVariance, df);
        Num = Like + PropN ;
        Like = -kowRatioLL(yslice, thetastarb, ...
                ObsPriorMean(selectC), ObsPriorVar(selectC,selectC), pslice, factor(c,:), StatePrecision) ;
        PropD = mvstudenttpdf(thetastarb, thetaMean, thetaVariance, df);
        Den = Like + PropD;
        alphagtostar = min(0,Num - Den);
        numeratorterm(r) = alphagtostar + PropD;
    end
    storePDFVals(c) = logAvg(numeratorterm') - logAvg(denominatorterm');
end
    
end


