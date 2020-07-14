function [pival] = piFtStar(FtStar, yt, Xbeta, currobsmod, stateTransitions,...
    obsPrecision, factorVariance, Identities, InfoCell)
[K,T] = size(yt);
nFactors = size(FtStar,1);
pival = zeros(nFactors,1);
fcount=0;
levels=length(InfoCell);
for q = 1:levels
    COM = makeStateObsModel(currobsmod, Identities, q);
    mut = Xbeta + COM*FtStar;
    ydemut = yt - mut;
    Info = InfoCell{1,q};
    regs = size(Info,1);
    ObsModel = currobsmod(:,q);
    
    for r=1:regs
        commonPrecisionComponent = zeros(T,T);
        commonMeanComponent = zeros(T,1);
        subset = Info(r,1):Info(r,2);
        fcount = fcount+1;
        for k = subset
            commonMeanComponent = commonMeanComponent + (ObsModel(k).*ydemut(k,:))'.*obsPrecision(k);
            commonPrecisionComponent = commonPrecisionComponent + ...
                (ObsModel(k)^2)*eye(T).*obsPrecision(k);
        end

        [L0, ssgam] = initCovar(stateTransitions(fcount,:), factorVariance(fcount));
        StatePrecision = FactorPrecision(ssgam, L0, 1./factorVariance(fcount), T);
        
        H = (StatePrecision + commonPrecisionComponent)\eye(T);
        mu = H*commonMeanComponent;
        

        pival(fcount) = logmvnpdf(FtStar(fcount,:), mu', H);
    end
end

end

