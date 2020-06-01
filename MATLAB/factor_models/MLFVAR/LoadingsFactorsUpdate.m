function [currobsmod, Ft, keepOmMeans, keepOmVariances, alpha] = ...
    LoadingsFactorsUpdate(yt, Xbeta, Ft, currobsmod, stateTransitions,...
    obsPrecision, factorVariance, Identities, InfoCell, keepOmMeans, keepOmVariances,...
    runningAverageMean, runningAverageVar, a0, A0inv)

options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-8, 'Display', 'iter', 'OptimalityTolerance', 1e-8, 'MaxIterations', 5);
df = 20;
[K,T] = size(yt);
w1 = sqrt(chi2rnd(df,1)/df);
fcount = 0;
levels = length(InfoCell);
nFactors = sum(cellfun(@(x)size(x,1), InfoCell));
alpha = zeros(nFactors,1);
xb = reshape(Xbeta, K,T);
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
        %% Optimization step
        %         for k =s2
        %             ty = ydemut(k,:);
        %             top = obsPrecision(k);
        %             x0 = currobsmod(k,q);
        %             LL = @(guess) -LLcond_ratio(guess, ty, a0, A0inv, top, tempf,StatePrecision);
        %             [themean, ~,~,~,~, Covar] = fminunc(LL, x0, options);
        %             Covar = (1/Covar)';
        %             if  Covar < 0
        %                 Covar = 1;
        %             end
        %             keepOmVariances(k,q)= Covar;
        %             keepOmMeans(k,q)=themean;
        %
        %             proposal = themean + diag(sqrt(Covar))*normrnd(0,1,1, 1)./w1;
        %             proposalDistNum = @(prop) mvstudenttpdf(prop, themean', diag(Covar), df);
        %             proposalDistDen = @(prop) mvstudenttpdf(prop, runningAverageMean(k,q)', diag(runningAverageVar(k,q)), df);
        %
        %             LogLikePositive = @(val) LLcond_ratio (val, ty, a0,A0inv, top, tempf, StatePrecision);
        %
        %             Num = LogLikePositive(proposal) + proposalDistNum(x0);
        %             Den = LogLikePositive(x0) + proposalDistDen(proposal');
        %             alpha(fcount) = min(0,Num - Den);
        %             u = log(unifrnd(0,1,1,1));
        %             if u <= alpha(fcount)
        %                 currobsmod(k,q) = proposal;
        %             end
        %         end
        
        
        
        ty = ydemut(s2,:);
        top = obsPrecision(s2);
        x0 = currobsmod(s2,q);
        a0m = a0.*ones(1,length(s2));
        A0invp = A0inv.*eye(length(s2));
        LL = @(guess) -LLcond_ratio(guess, ty, a0m, A0invp, top, tempf,StatePrecision);
        [themean, ~,~,~,~, Covar] = fminunc(LL, x0, options);
        H = Covar\eye(length(s2));
        [Hlower, p] = chol(H,'lower');
        if p ~= 0 
            Hlower = eye(length(s2));
            H = eye(length(s2));
        end
        ty = ydemut(subset,:);
        ty = ty(2:end,:);
        top = obsPrecision(subset);
        top = top(2:end);
        
        proposal = themean + Hlower*normrnd(0,1,length(s2), 1)./w1;
        proposalDist= @(prop) mvstudenttpdf(prop, themean', H, df);
        
        LogLikePositive = @(val) LLcond_ratio (val, ty, a0m,A0invp, top, tempf, StatePrecision);
        Num = LogLikePositive(proposal) + proposalDist(x0');
        Den = LogLikePositive(x0) + proposalDist(proposal');
        alpha(fcount) = min(0,Num - Den);
        u = log(unifrnd(0,1,1,1));
        if u <= alpha(fcount)
            currobsmod(subset,q) = [1;proposal];
        end
        %% Update Factor
        ty = ydemut(subset,:);
        top = obsPrecision(subset);
        Ft(fcount,:) =  kowUpdateLatent(ty(:), currobsmod(subset,q), StatePrecision, top);
    end
end

end