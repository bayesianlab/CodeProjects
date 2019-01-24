function [obsupdate, lastMeanUpdate, lastHessianUpdate,f  ] = ...
    kowWorldBlocks( yt, precision, WorldObsModel, StateTransition,...
    blocks, lastMean, lastHessian, PriorPre, logdetPriorPre, ObsPriorMean,ObsPriorVar, factor, i, burnin )
[nEqns, T] = size(yt);
obsupdate = zeros(length(WorldObsModel),1);
EqnsPerblock = nEqns/blocks;
lastMeanUpdate = zeros(EqnsPerblock, blocks);
lastHessianUpdate = zeros(EqnsPerblock, EqnsPerblock, blocks);
select = 1:EqnsPerblock;
StatePrecision = kowStatePrecision(StateTransition, 1, T);

for b = 1:blocks
    index = select + (b-1)*EqnsPerblock;
    yslice = yt(index,:);
    pslice = precision(index);
    guess = WorldObsModel(index);
   if b == 1
       Restricted = 1;
       [obsupdate(index), lastMeanUpdate(:,1), lastHessianUpdate(:,:,1)] =...
           kowObsModelUpdate(guess, pslice, StatePrecision, lastMean(:,b),...
                lastHessian(:,:,b), Restricted, PriorPre, logdetPriorPre,...
                ObsPriorMean(index),ObsPriorVar(index,index), factor, yslice, i, burnin);
   else
       Restricted = 0;
       [obsupdate(index), lastMeanUpdate(:,b), lastHessianUpdate(:,:,b)] =...
           kowObsModelUpdate( guess, pslice, StatePrecision, lastMean(:,b),...
                lastHessian(:,:,b), Restricted, PriorPre,logdetPriorPre,...
                 ObsPriorMean(index),ObsPriorVar(index,index), factor, yslice, i, burnin);
   end
end
f = kowUpdateLatent(yt(:),obsupdate, StatePrecision, precision)';
end

