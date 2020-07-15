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
    for r=1:regs
        subset = Info(r,1):Info(r,2);
        fcount = fcount+1;
        ty = ydemut(subset,:);
        top = obsPrecision(subset);
        gammas = stateTransitions(fcount,:);
        factorVariance(fcount) = 1;
        L0 = initCovar(gammas, factorVariance(fcount));
        StatePrecision = FactorPrecision(gammas, L0, 1./factorVariance(fcount), T);
        pival(fcount,:) =  factor_pdf(FtStar(fcount,:), ty(:), currobsmod(subset,q), StatePrecision, top);
    end
end
end

