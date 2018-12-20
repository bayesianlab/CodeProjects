function [  ] = kowWorldBlocks( yt, precision, WorldObsModel, StateTransition,...
    blocks, lastMean, lastHessian )
[nEqns, T] = size(yt);

EqnsPblock = nEqns/blocks;
select = 1:EqnsPblock;
for b = 1:blocks
    index = select + (b-1)*EqnsPblock;
    yslice = yt(index,:);
    pslice = precision(index);
    guess = WorldObsModel(index);
   if b == 1
       Restricted = 1;
       kowObsModelUpdate(yslice(:), pslice, StateTransition, lastMean, lastHessian, Restricted, guess)
   else
       Restricted = 0;
       kowObsModelUpdate(yslice(:), pslice, StateTransition, lastMean, lastHessian, Restricted, guess)
   end
end



end

