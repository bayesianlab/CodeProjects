function [obsupdate, lastMeanUpdate, lastHessianUpdate,f  ] = ...
    kowWorldBlocks( yt, precision, WorldObsModel, StateTransition,...
    blocks, lastMean, lastHessian, PriorPre, logdetPriorPre )
[nEqns, T] = size(yt);
obsupdate = zeros(length(WorldObsModel),1);
EqnsPerblock = nEqns/blocks;
lastMeanUpdate = zeros(EqnsPerblock, blocks);
lastHessianUpdate = zeros(EqnsPerblock, EqnsPerblock, blocks);
select = 1:EqnsPerblock;
StatePrecision = kowMakePrecision(StateTransition, 1, T);
for b = 1:blocks
    index = select + (b-1)*EqnsPerblock;
    yslice = yt(index,:);
    pslice = precision(index);
    guess = WorldObsModel(index);
   if b == 1
       Restricted = 1;
       [obsupdate(index), lastMeanUpdate(:,1), lastHessianUpdate(:,:,1)] =...
           kowObsModelUpdate(yslice(:), pslice, StatePrecision, lastMean(:,b),...
           lastHessian(:,:,b), Restricted, PriorPre, logdetPriorPre, guess);
   else
       Restricted = 0;
       [obsupdate(index), lastMeanUpdate(:,b), lastHessianUpdate(:,:,b)] =...
           kowObsModelUpdate(yslice(:), pslice, StatePrecision, lastMean(:,b),...
           lastHessian(:,:,b), Restricted, PriorPre,logdetPriorPre, guess);
   end
end
f = kowUpdateLatent(yt(:),obsupdate, StatePrecision, precision)';
end

