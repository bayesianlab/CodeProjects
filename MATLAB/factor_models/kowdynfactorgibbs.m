function [  ] = kowdynfactorgibbs(KowData, restrictedStateVar, b0, B0inv,Sims )
N=60;
K=3;

storebeta = zeros(N*K, Sims);

currobsmod = unifrnd(.5,1,60,3);
obsvars = unifrnd(.1,1, 60,1);
for i = 1 : Sims
    
    beta = kowupdateBetaPriors(KowData, currobsmod, obsvars, restrictedStateVar, b0, B0inv);
    storebeta(:,i) = beta;
    
    
    
end
end
