function [FtUpdate] = drawFactor(Ft, yt, Xbeta, currobsmod, stateTransitions,...
    obsPrecision, factorVariance, Identities, InfoCell, varargin)
if nargin > 10
    ar = varargin{1};
else
    ar=0;
end
[K,T] = size(yt);
nFactors = size(stateTransitions,1);
fcount=0;
levels=length(InfoCell);
FtUpdate = zeros(nFactors,T);
for q = 1:levels
    COM = makeStateObsModel(currobsmod, Identities, q);
    mut = Xbeta + COM*Ft;
    ydemut = yt - mut;
    Info = InfoCell{1,q};
    regs = size(Info,1);
    
    for r=1:regs
        
        subset = Info(r,1):Info(r,2);
        fcount = fcount+1;
        
        ty = ydemut(subset,:);
        top = obsPrecision(subset);
        gammas = stateTransitions(fcount,:);
        L0 = initCovar(gammas, factorVariance(fcount));
        StatePrecision = FactorPrecision(gammas, L0, 1./factorVariance(fcount), T);
        FtUpdate(fcount,:) =  kowUpdateLatent(ty(:), currobsmod(subset,q), StatePrecision, top);
        
    end
end
end

