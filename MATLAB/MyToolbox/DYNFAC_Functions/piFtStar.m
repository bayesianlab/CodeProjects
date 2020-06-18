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
        [L0, ssgam] = initCovar(stateTransitions(fcount,:), factorVariance(fcount));
        StatePrecision = FactorPrecision(ssgam, L0, 1./factorVariance(fcount), T);
        ty = ydemut(subset,:);
        top = obsPrecision(subset);
        ObsModel = currobsmod(subset,q);
        eyet = eye(T);
        FullPrecision = diag(top);
        GtO = ObsModel'*FullPrecision;
        P = StatePrecision + kron(eyet, GtO*ObsModel);
        LP = chol(P,'lower');
        LPi = LP\eye(size(P,1));
        B = LPi'*LPi;
        mu = B*(kron(eyet,GtO)*ty(:));
        pival(fcount) = logmvnpdf(FtStar(fcount,:), mu', B);
    end
end

end

