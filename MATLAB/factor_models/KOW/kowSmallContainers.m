function [sumFt,sumFt2, sumResiduals2, storeFt, storeBeta,...
 storeObsVariance, storeObsModel, storeStateTransitions] = kowSmallContainers(Sims,burnin, betaDim,...
        NumberYequations, NumberTimePeriods,NumberOfFactors)
sumFt = zeros(NumberOfFactors, NumberTimePeriods);
sumFt2 = sumFt;
sumResiduals2 = zeros(NumberYequations,1);
storeFt = zeros(NumberOfFactors,NumberTimePeriods, Sims-burnin);
storeBeta = zeros(betaDim, Sims -burnin);
storeObsVariance = zeros(NumberYequations,Sims -burnin);
storeObsModel = zeros(NumberYequations, 1, Sims-burnin);
storeStateTransitions = zeros(NumberOfFactors, 1, Sims-burnin);
end

