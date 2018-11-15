function [ fsto] = kowUpdateLatentStates( y, ObsModel,  ObsModelVariances,StateTransition, eqnsIndices)
Subsets = size(eqnsIndices,1);
T = size(y,2);
fsto = zeros(Subsets, T);
for r = 1:Subsets
    first=eqnsIndices(r,1);
    last=eqnsIndices(r,2);
    select = first:last;
    ytemp = y(select,:);
    [P0region, ~, ~] = kowKalmanInitRecursion(StateTransition(r,:), [1,0,0]', 1);
    Si = kowMakeVariance(StateTransition(r,:), P0region, 1, T);
    fsto(r, :) = kowUpdateLatent(ytemp(:), Si, ObsModel(select), ObsModelVariances(select));
end


end
