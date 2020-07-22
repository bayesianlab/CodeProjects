function [storeMeans, storeVars] = ...
    ComputeMeansVars(yt, Xbeta, Ft, currobsmod, stateTransitions,...
    obsPrecision, factorVariance, Identities, InfoCell, a0, A0)

options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-8, 'Display', 'off', 'OptimalityTolerance', 1e-8, 'MaxIterations', 25);
df = 20;
[K,T] = size(yt);
fcount = 0;
levels = length(InfoCell);
nFactors = sum(cellfun(@(x)size(x,1), InfoCell));
xb = reshape(Xbeta, K,T);
storeMeans = cell([1,nFactors]);
storeVars = storeMeans;
for q = 1:levels
    COM = makeStateObsModel(currobsmod, Identities, q);
    mut =  xb + COM*Ft;
    ydemut = yt - mut;
    Info = InfoCell{1,q};
    region = size(Info,1);
    for r=1:region
        fcount = fcount+1;
        gammas = stateTransitions(fcount,:);
        L0 = initCovar(gammas, factorVariance(fcount));
        StatePrecision = FactorPrecision(gammas, L0, 1./factorVariance(fcount), T);
        tempf = Ft(fcount,:);
        subset = Info(r,1):Info(r,2);
        s2 = (Info(r,1)+1):Info(r,2);

        ty = ydemut(s2,:);
        top = obsPrecision(s2);
        x0 = currobsmod(s2,q);
        a0m = a0.*ones(1,length(s2));
        A0invp = (1/A0).*eye(length(s2));
        LL = @(guess) -LLcond_ratio(guess, ty, a0m, A0invp, top, tempf,StatePrecision);
        [themean, ~,~,~,~, Covar] = fminunc(LL, x0, options);
        H = Covar\eye(length(s2));
        [Hlower, p] = chol(H,'lower');
        if p ~= 0 
            Hlower = eye(length(s2));
            H = eye(length(s2));
        end        
        storeMeans{fcount} = themean;
        storeVars{fcount} = H;


    end
end

end