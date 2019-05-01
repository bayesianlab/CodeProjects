function [] = ML_MDFVar_Sim_Version_Id2(yt, obsVarianceStar, v0,r0, s0,d0, avgFactorVar,...
    meanFactorParamb, stateTransitionMatrix, stateTransitionStar, avgFt)

[K,T] = size(yt);
obsPrecisionStar = 1./obsVarianceStar;
piObsVarianceStar = logigampdf(obsPrecisionStar, .5.*(T+v0), .5.*(avgResidualsSqd + r0));
piFactorVarianceStar = logigampdf(avgFactorVar, .5.*(T+s0), .5.*(d0+meanFactorParamb))
piFactorTransitionStar = kowArMl(stateTransitionMatrix, stateTransitionStar, avgFt);

% for i = 1 : Sims
%     fprintf('\nSimulation %i\n',i)
%     
%     %% Update loadings and factors
%     
%     for q = [1,3]
%         ConditionalObsModel = makeStateObsModel(currobsmod, Identities, q);
%         ty = yt - ConditionalObsModel*Ft;
%         Info = InfoCell{1,q};
%         factorIndx = factorInfo(q,:);
%         factorSelect = factorIndx(1):factorIndx(2);
%         factorVarianceSubset = factorVariance(factorSelect);
%         tempbackup = backupMeanAndHessian(factorSelect,:);
%         [currobsmod(:,q), tempbackup, f, ~] = AmarginalF(Info, ...
%             Ft(factorSelect, :), ty, currobsmod(:,q), stateTransitions(factorSelect), factorVarianceSubset,...
%             obsPrecision, tempbackup, options, identification, vy);
%         backupMeanAndHessian(factorSelect,:) = tempbackup;
%         Ft(factorSelect,:) = f;
%         
%     end
%     
%     StateObsModel = makeStateObsModel(currobsmod,Identities,0);
%     
% end
end