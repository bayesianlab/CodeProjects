function [ alpha ] = mhStepMvProbit(Wstar, Dstar, Rstar, W0, D0,...
    R0, wprior, wishartDf, latentData, meanLatentData) 
% surLL computes by row for every column!
Num = logpxWishart(Dstar,Rstar,wishartDf, wprior) + ...
      surLL(latentData,meanLatentData,Rstar) + ...
      logInvWish(W0, Wstar, wishartDf) ;
Den = logpxWishart(D0,R0,wishartDf, wprior) + ...
      surLL(latentData,meanLatentData,R0) + ...
      logInvWish(Wstar, W0, wishartDf);
%     A = logpxWishart(Dstar,Rstar,wishartDf, wprior);
%     B = surLL(latentData,meanLatentData,Rstar);
%     C = logwish(W0, Wstar, wishartDf);
%     D = logpxWishart(D0,R0,wishartDf, wprior);
%     E = surLL(latentData,meanLatentData,R0);
%     F = logwish(W0, Wstar, wishartDf);
%   NumVals = [A,B,C]
%   DenVals = [C,D,E]
%   pxmpx = [A-C]
%   Dstar
%   Rstar
%   D0
%   R0
 
alpha = min(0, Num - Den);
end

