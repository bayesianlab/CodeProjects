function [ alpha ] = mhStepMvProbit(Wstar, Dstar, Rstar, W0, D0,...
    R0, wprior, wishartDf, latentData, meanLatentData) 
[pdfvalnum, jacnum] = logpxWishart(Dstar,Rstar,wishartDf, wprior);
[pdfvalden, jacden] = logpxWishart(D0,R0,wishartDf, wprior);
% surLL computes by row for every column!
Num =  pdfvalnum + ...
      surLL(latentData,meanLatentData,Rstar) + ...
       specialLogWishart(jacnum, W0, Wstar, wishartDf);
Den = pdfvalden+ ...
      surLL(latentData,meanLatentData,R0) + ...
       specialLogWishart(jacden, Wstar, W0, wishartDf);
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

