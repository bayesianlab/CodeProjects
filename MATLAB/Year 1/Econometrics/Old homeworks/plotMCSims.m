function [] = plotMCSims(X, nSims)
% Takes an error vector and returns Monte Carlo Simulations 
% of the beta hats. Called by controller. Import data first. 

beta = [2; 4];
X = [ones(length(X),1) X];
nBins = 50;

subplotCounter = 1;
for i = 1:3
    
   sample = 10^i;
   figure
   title('Truth')
   subplot(3,1,subplotCounter)
   hist(monteCarloNormalEr(nSims,sample, X, beta), nBins)
   str = sprintf('Beta = 4. Normal Errors, Sample Sizes %i MC Sims', 10^i);
   title(str)
   
   subplot(3,1,subplotCounter+1)
   hist(monteCarloCauchy(nSims, sample, X, beta), nBins)
   title('Beta = 4. Cauchy Errors, Sample Sizes 10, 100, 1000. 10,000 MC Sims')
   
   subplot(3,1,subplotCounter+2)
   hist(monteCarloBinary(nSims, sample, X, beta), nBins)
   title('Beta = 4. Binary Errors, Sample Sizes 10, 100, 1,000. 10,000 MC Sims')
   
   subplotCounter= 1;
   
end
end