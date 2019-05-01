function [] = MLFML(yt,Xt, gammaStar, obsVarianceStar ,nFactors, ReducedRuns)
[K,T] = size(yt);




% Sstar = kowStatePrecision(gammaStar.*eye(nFactors), 1, T);
obsPrecisionStar = 1./obsVarianceStar
% omegaGammaParameter = sumResiduals2./Runs;
% storeRRobsModel = zeros(K, 3, ReducedRuns);
% Astar = zeros(K,3);
% 
% 
% % pistarObsModelVariance 
% if nomean == 1
%     
% else
%     betaDim = size(Xt,2);
%     sumBetaVar = zeros(betaDim,betaDim);
%     for rr = 1:3
%         fprintf('Reduced Run %i\n', rr)
%         if rr == 1
%             for n = 1:ReducedRuns
%                 %% Reduced Run 1
%                 [beta, ydemut, betaVar] = kowBetaUpdate(yt(:), Xt, obsPrecision,...
%                     StateObsModel,Si,T);
%                 
%                 sumBetaVar = sumBetaVar + betaVar;
%                 betaStar = betaStar + beta;
%                 
%                 NoWorld = makeStateObsModel([zerooutworld, currobsmod(:,2:3)],IRegion,ICountry) ;
%                 ty = ydemut - NoWorld*Ft;
%                 currobsmod(:,1) = AmarginalF(SeriesPerCountry, InfoMat, ...
%                     Ft(1, :), ty, currobsmod(:,1), stateTransitions(1), obsPrecision, ...
%                     backupMeanAndHessian, 1);
%                 Ft(1,:) = kowUpdateLatent(ty(:), currobsmod(:,1),...
%                     kowStatePrecision(stateTransitions(1), 1,T), obsPrecision);
%                 
%                 NoRegion = makeStateObsModel(currobsmod, zerooutregion, ICountry);
%                 ty = ydemut - NoRegion*Ft;
%                 currobsmod(:,2) = AmarginalF(SeriesPerCountry, InfoMat, ...
%                     Ft(RegionIndicesFt, :), ty, currobsmod(:,2), stateTransitions(RegionIndicesFt), obsPrecision, ...
%                     backupMeanAndHessian,2);
%                 vecf = kowUpdateLatent(ty(:), currobsmod(:,2).*IRegion,...
%                     kowStatePrecision(stateTransitions(RegionIndicesFt).*eye(Regions), 1,T), obsPrecision)';
%                 Ft(RegionIndicesFt,:) = reshape(vecf, Regions, T);
%                 
%                 NoCountry = makeStateObsModel(currobsmod, IRegion, zerooutcountry);
%                 ty = ydemut - NoCountry*Ft;
%                 currobsmod(:,3) = AmarginalF(SeriesPerCountry, InfoMat, ...
%                     Ft(CountryIndicesFt, :), ty, currobsmod(:,3), stateTransitions(CountryIndicesFt), obsPrecision, ...
%                     backupMeanAndHessian, 3);
%                 vecf = kowUpdateLatent(ty(:), currobsmod(:,3).*ICountry,...
%                     kowStatePrecision(stateTransitions(CountryIndicesFt).*eye(Countries), 1,T), obsPrecision);
%                 Ft(CountryIndicesFt,:) = reshape(vecf, Countries,T);
%                 
%                 StateObsModel = makeStateObsModel(currobsmod,IRegion,ICountry);
%             end
%             betaStar = betaStar./ReducedRuns;
%             sumBetaVar = sumBetaVar./ReducedRuns;
%             ydemut = reshape(yt(:) - Xt*betaStar, K, T);
%         elseif rr == 2
%             for n = 1:ReducedRuns
%                 
%                 NoWorld = makeStateObsModel([zerooutworld, currobsmod(:,2:3)],IRegion,ICountry) ;
%                 ty = ydemut - NoWorld*Ft;
%                 currobsmod(:,1) = AmarginalF(SeriesPerCountry, InfoMat, ...
%                     Ft(1, :), ty, currobsmod(:,1), stateTransitions(1), obsPrecision, ...
%                     backupMeanAndHessian, 1);
%                 Ft(1,:) = kowUpdateLatent(ty(:), currobsmod(:,1),...
%                     kowStatePrecision(stateTransitions(1), 1,T), obsPrecision);
%                 
%                 NoRegion = makeStateObsModel(currobsmod, zerooutregion, ICountry);
%                 ty = ydemut - NoRegion*Ft;
%                 currobsmod(:,2) = AmarginalF(SeriesPerCountry, InfoMat, ...
%                     Ft(RegionIndicesFt, :), ty, currobsmod(:,2), stateTransitions(RegionIndicesFt), obsPrecision, ...
%                     backupMeanAndHessian,2);
%                 vecf = kowUpdateLatent(ty(:), currobsmod(:,2).*IRegion,...
%                     kowStatePrecision(stateTransitions(RegionIndicesFt).*eye(Regions), 1,T), obsPrecision)';
%                 Ft(RegionIndicesFt,:) = reshape(vecf, Regions, T);
%                 
%                 NoCountry = makeStateObsModel(currobsmod, IRegion, zerooutcountry);
%                 ty = ydemut - NoCountry*Ft;
%                 currobsmod(:,3) = AmarginalF(SeriesPerCountry, InfoMat, ...
%                     Ft(CountryIndicesFt, :), ty, currobsmod(:,3), stateTransitions(CountryIndicesFt), obsPrecision, ...
%                     backupMeanAndHessian, 3);
%                 vecf = kowUpdateLatent(ty(:), currobsmod(:,3).*ICountry,...
%                     kowStatePrecision(stateTransitions(CountryIndicesFt).*eye(Countries), 1,T), obsPrecision);
%                 Ft(CountryIndicesFt,:) = reshape(vecf, Countries,T);
%                 
%                 StateObsModel = makeStateObsModel(currobsmod,IRegion,ICountry);
%                 
%                 storeRRobsModel(:,:,n) = currobsmod;
%                 
%                 sumLastHessianCountry = sumLastHessianCountry + lastHessianCountry;
%                 sumLastHessianRegion = sumLastHessianRegion + lastHessianRegion;
%                 sumLastHessianWorld = sumLastHessianWorld + lastHessianWorld;
%                 sumLastMeanCountry = sumLastMeanCountry + lastMeanCountry;
%                 sumLastMeanRegion = sumLastMeanRegion + lastMeanRegion;
%                 sumLastMeanWorld = sumLastMeanWorld + lastMeanWorld;
%             end
%             Astar = mean(storeRRobsModel,3);
%             StateObsModelStar = [Astar(:,1), IRegion .* Astar(:,2),...
%                 ICountry .* Astar(:,3)];
%             sumLastHessianCountry = sumLastHessianCountry./ReducedRuns;
%             sumLastHessianRegion = sumLastHessianRegion./ReducedRuns;
%             sumLastHessianWorld = sumLastHessianWorld./ReducedRuns;
%             sumLastMeanCountry = sumLastMeanCountry./ReducedRuns;
%             sumLastMeanRegion = sumLastMeanRegion ./ ReducedRuns;
%             sumLastMeanWorld = sumLastMeanWorld ./ReducedRuns;
%             Astar = Astar./ReducedRuns;
%         else
%             StateObsModelStar = [Astar(:,1), IRegion .* Astar(:,2),...
%                 ICountry .* Astar(:,3)];
%             for n = 1:ReducedRuns
%                 [Ftrr, P] = kowUpdateLatent(ydemut(:), StateObsModelStar, Sstar,...
%                     obsPrecisionStar);
%                 sumFtRR = sumFtRR + Ftrr;
%             end
%         end
%     end
%     
%     Ftstar = sumFtRR./ReducedRuns;
%     pistargamma = kowArMl(storeStateTransitions, gammaStar, sumFt);
%     Ftstart = reshape(Ftstar,nFactors,T);
%     piastarworld = kowObsModelReducedRunWorld(squeeze(storeRRobsModel(:,1,:)),...
%         ydemut, obsPrecisionStar, Astar(:,1), sumLastMeanWorld,...
%         sumLastHessianWorld, WorldAr, blocks, K,...
%         ObsPriorMean, ObsPriorVar, Ftstart(1,:));
%     piastarregion = kowObsModelReducedRunRegion(squeeze(storeRRobsModel(:,2,:)), ydemut,...
%         obsPrecisionStar, Astar(:,2), sumLastMeanRegion,...
%         sumLastHessianRegion, RegionAr, blocksRegion, K,...
%         CountriesThatStartRegions,  ObsPriorMean, ObsPriorVar, Ftstart(RegionIndicesInFt,:));
%     piastarcountry = kowObsModelReducedRunCountry(squeeze(storeRRobsModel(:,3,:)),...
%         ydemut, obsPrecisionStar, Astar(:,3), sumLastMeanCountry,...
%         sumLastHessianCountry, CountryAr, Countries,...
%         ObsPriorMean, ObsPriorVar, Ftstart(CountryIndicesInFt,:));
%     
%     % Integrate out Ft
%     mu2 = StateObsModelStar*Ftstart;
%     nomeany = ydemut(:) - mu2(:);
%     OmegaStar = spdiags(repmat(omegaStar, T,1), K*T,K*T);
%     fyGivenThetaStar = logmvnpdf(nomeany', zeros(1, K*T), OmegaStar) +...
%         logmvnpdf(Ftstar, zeros(1,nFactors*T), eye(nFactors*T)*100) -...
%         logmvnpdf(Ftstar,Ftstar, P);
%     % ML calc
%     priorBetaStar = logmvnpdf(betaStar', zeros(1,betaDim), eye(betaDim)*100);
%     priorAstar = logmvnpdf(Astar, zeros(size(Astar,1), size(Astar,2)),...
%         eye(size(Astar,2)).*100)';
%     priorOmegaStar = logigampdf(obsPrecisionStar, .5*v0, .5*r0);
%     priorGammaStar = logmvnpdf(gammaStar, zeros(size(gammaStar,1), size(gammaStar,2)),...
%         eye(size(gammaStar,2)).*100)';
%     priorStar = sum([priorBetaStar;priorAstar;priorOmegaStar;priorGammaStar]);
%     posteriorStar = sum([pistargamma;...
%         logigampdf(omegaStar, (T+v0)/2, (omegaGammaParameter + r0)./2);...
%         logmvnpdf(betaStar',betaStar', sumBetaVar);...
%         piastarcountry;piastarworld;piastarregion],1);
%     ml = fyGivenThetaStar + priorStar - posteriorStar;
% end
end
