function [currobsmod, Ft, alpha,  accept] = ...
    mvp_LoadFacUpdate(yt, Xbeta, Ft, currobsmod, stateTransitions,...
    obsPrecision, factorVariance, Identities, InfoCell,  a0, A0)

options = optimoptions(@fminunc,'FiniteDifferenceType', 'forward',...
    'StepTolerance', 1e-8, 'Display', 'off', 'OptimalityTolerance', 1e-8, 'MaxIterations', 25);
df = 20;
[K,T] = size(yt);
w1 = sqrt(chi2rnd(df,1)/df);
fcount = 0;
levels = length(InfoCell);
nFactors = sum(cellfun(@(x)size(x,1), InfoCell));
alpha = zeros(nFactors,1);
xb = reshape(Xbeta, K,T);
accept = zeros(nFactors,1);
for q = 1:levels
    COM = makeStateObsModel(currobsmod, Identities, q);
    mut =  xb + COM*Ft;
    ydemut = yt - mut;
    Info = InfoCell{1,q};
    region = size(Info,1);
    for r=1:region
        fcount = fcount+1;
        gammas = stateTransitions(fcount,:);
        L0 = initCovar(gammas, 1);
        StatePrecision = FactorPrecision(gammas, L0, 1, T);
        tempf = Ft(fcount,:);
        subset = Info(r,1):Info(r,2);

        ty = ydemut(subset,:);
        top = obsPrecision(subset);
        x0 = currobsmod(subset,q);
        lsub = length(subset);
        a0m = a0.*ones(1,lsub);
        A0invp = (1/A0).*eye(lsub);
        LL = @(guess) -LLcond_ratio(guess, ty, a0m, A0invp, top, tempf,StatePrecision);
        [themean, ~,~,~,~, Covar] = fminunc(LL, x0, options);
        H = Covar\eye(length(subset));
        [Hlower, p] = chol(H,'lower');
        if p ~= 0 
            Hlower = eye(length(subset));
            H = eye(length(s2));
        end

        
        proposal = themean + Hlower*normrnd(0,1, lsub, 1)./w1;
        if proposal(1) <0 
            proposal(1) = abs(proposal(1));
        end
        C = diag(proposal*proposal' + eye(lsub));        
        D = diag(C.^(-.5));
        d= diag(D);
        proposal= D*proposal;
        
        
%         TOM(subset,q) = proposal;
%         MU{fcount} = themean;
%         VARIANCE{fcount} = H ;
        
        proposalDist= @(prop) mvstudenttpdf(prop, themean', H, df);
        LogLikePositive = @(val) LLcond_ratio (val, ty, a0m,A0invp, top, tempf, StatePrecision);
        Num = LogLikePositive(proposal) + proposalDist(x0');
        Den = LogLikePositive(x0) + proposalDist(proposal');
        alpha(fcount) = min(0,Num - Den);
        u = log(unifrnd(0,1,1,1));
        if u <= alpha(fcount)
            accept(fcount) =  1;
            currobsmod(subset,q) = proposal;
        end
        
        % Update Factor
        

        
        Ft(fcount,:) =  kowUpdateLatent(ty(:), currobsmod(subset,q), StatePrecision, 1./d);
    end
end

% fcount = 0;
% for q = 1:levels
%     COM = makeStateObsModel(currobsmod, Identities, q);
%     mut =  xb + COM*Ft;
%     ydemut = yt - mut;
%     Info = InfoCell{1,q};
%     region = size(Info,1);
%     for r=1:region
%         fcount = fcount+1;
%         gammas = stateTransitions(fcount,:);
%         L0 = initCovar(gammas, factorVariance(fcount));
%         StatePrecision = FactorPrecision(gammas, L0, 1./factorVariance(fcount), T);
%         tempf = Ft(fcount,:);
%         subset = Info(r,1):Info(r,2);
% 
%         ty = ydemut(subset,:);
%         top = obsPrecision(subset);
%         x0 = currobsmod(subset,q);
%         lsub = length(subset);
%         a0m = a0.*ones(1, lsub);
%         A0invp = (1/A0).*eye(lsub);
%         LL = @(guess) -LLcond_ratio(guess, ty, a0m, A0invp, top, tempf,StatePrecision);
% 
%         proposal = TOM(subset,q);
%         themean = MU{q};
%         H = VARIANCE{q};
%         proposalDist= @(prop) mvstudenttpdf(prop, themean', H, df);
%         Num = -LL(proposal) + proposalDist(x0');
%         Den = -LL(x0) + proposalDist(proposal');
%         alpha(fcount) = min(0,Num - Den);
%         u = log(unifrnd(0,1,1,1));
%         if u <= alpha(fcount)
%             accept(fcount) =  1;
%             currobsmod(subset,q) = TOM(subset,q);
%         end
% 
%     end
% end
% 
% fcount = 0;
% for q = 1:levels
%     COM = makeStateObsModel(currobsmod, Identities, q);
%     mut =  xb + COM*Ft;
%     ydemut = yt - mut;
%     Info = InfoCell{1,q};
%     region = size(Info,1);
%     for r=1:region
%         fcount = fcount+1;
%         gammas = stateTransitions(fcount,:);
%         L0 = initCovar(gammas, factorVariance(fcount));
%         StatePrecision = FactorPrecision(gammas, L0, 1./factorVariance(fcount), T);
%         subset = Info(r,1):Info(r,2);
%         lsub = length(subset);
% 
%         ty = ydemut(subset,:);
%         tom = TOM(subset,q);
%         d = diag(tom*tom' + eye(lsub));
%         top = 1./d;
%         
%         Ft(fcount,:) =  kowUpdateLatent(ty(:), currobsmod(subset,q), StatePrecision, top);
% 
%     end
% end

%         C = diag([1;proposal]*[1;proposal]' + eye(ns2+1));
%         D = diag(C.^(-.5));
%         d= diag(D);
%         temp = D*[1;proposal];
%         proposal = temp(2:end);
%
%         proposalDist= @(prop) mvstudenttpdf(prop, themean', H, df);
%         Num = -LL(proposal) + proposalDist(x0');
%         Den = -LL(x0) + proposalDist(proposal');
%         alpha(fcount) = min(0,Num - Den);
%         u = log(unifrnd(0,1,1,1));
%         if u <= alpha(fcount)
%             accept(fcount) =  1;
%             currobsmod(subset,q) = [temp(1);proposal];
%         end
%
%         %% Update Factor
%         ty = ydemut(subset,:);
%
%         top = diag(D*eye(ns2+1));
%
%         Ft(fcount,:) =  kowUpdateLatent(ty(:), currobsmod(subset,q), StatePrecision, top);
% 
% 
% end