function [] = MLMLDFVAR(Sims, yt, Xt, Ft, obsPrecision, StateTransitions, sumOM,...
    backupMeanAndHessian, InfoCell,options, v0, r0, nomean)

[K,T] = size(yt);
[nFactors, ~ ] = size(Ft);
[~, levels] = size(sumOM);
currobsmod = sumOM;
[Identities, sectorInfo, factorInfo] =  MakeObsModelIdentity( InfoCell);
if nomean == 1
    ReducedRuns = 3;
    stateTransStar = mean(StateTransitions,3);
    piStateStar = kowArMl(StateTransitions, stateTransStar, Ft);
    
    sumObsPrecision = zeros(K,1);
    storer2 = zeros(K,Sims);
    storeObsModel = zeros(K, levels,Sims);
    storeThetagParams = cell(levels,2);
    for r = 1:Sims
        %% Obtain pi(Sigma*|y, stateTrans*)
        for q = 1:levels
            ConditionalObsModel = makeStateObsModel(currobsmod, Identities, q);
            ty = yt - ConditionalObsModel*Ft;
            Info = InfoCell{1,q};
            factorIndx = factorInfo(q,:);
            factorSelect = factorIndx(1):factorIndx(2);
            tempbackup = backupMeanAndHessian(factorSelect,:);
            [currobsmod(:,q), tempbackup, f] = AmarginalF(Info, ...
                Ft(factorSelect, :), ty, currobsmod(:,q), stateTransStar(factorSelect), obsPrecision, ...
                tempbackup, options);
            backupMeanAndHessian(factorSelect,:) = tempbackup;
            Ft(factorSelect,:) = f;
        end
        StateObsModel = makeStateObsModel(currobsmod,Identities,0);
        
        %% Variance
        residuals = yt - StateObsModel*Ft;
        [obsVariance,r2] = kowUpdateObsVariances(residuals, v0,r0,T);
        obsPrecision = 1./obsVariance;
        sumObsPrecision = sumObsPrecision + obsPrecision;
        storer2(:,r) = r2;
    end
    obsPrecisionStar = sumObsPrecision./Sims;
    piVarStar = piObsVarianceStar(1./obsPrecisionStar, .5*v0, .5.*storer2);
    
    %%  get pi(ObsModel*|y, Sigma*, stateTrans*)
    
    
    for r = 1:Sims

        for q = 1:levels
            sectorInfo(q)        
            
            
            ConditionalObsModel = makeStateObsModel(currobsmod, Identities, q);
            ty = yt - ConditionalObsModel*Ft;
            Info = InfoCell{1,q};
            factorIndx = factorInfo(q,:);
            factorSelect = factorIndx(1):factorIndx(2);
            tempbackup = backupMeanAndHessian(factorSelect,:);
            
           
            
            [currobsmod(:,q), tempbackup, f] = AmarginalF(Info, ...
                Ft(factorSelect, :), ty, currobsmod(:,q), stateTransStar(factorSelect), obsPrecisionStar, ...
                tempbackup, options);
            backupMeanAndHessian(factorSelect,:) = tempbackup;
            
            Ft(factorSelect,:) = f;
        end
        storeObsModel(:,:,r) = currobsmod;
    end
    
    
    %%%%%%%%%%%%%%%%%%
    
else
    ReducedRuns = 4;
    betaDim = size(Xt,2);
    sumBetaVar = zeros(betaDim,betaDim);
    for rr = 1:3
        fprintf('Reduced Run %i\n', rr)
        if rr == 1
            for n = 1:ReducedRuns
                %% Reduced Run 1
                
            end
            
        elseif rr == 2
            for n = 1:ReducedRuns
                
                
            end
            
        else
            
            for n = 1:ReducedRuns
                
            end
        end
    end
    
    
    
    
end
end
