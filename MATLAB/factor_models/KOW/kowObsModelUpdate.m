function [  ] = kowObsModelUpdate(vecy, precision, StateTransition, oldMean,...
    oldHessian, Restricted, guess)

options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
        'Display', 'off');
T = length(vecy)/length(precision) 
StatePrecision = kowMakePrecision(StateTransition, 1, T);
oldMean
oldHessian
[themean,Hessian] = kowOptimize(guess, vecy, StatePrecision,precision,oldMean,...
    oldHessian, options, 1)

% if Restricted == 1
%     kowMHR
% else
%     kowMhUR
% end
end

