function [ themean,Hessian,lastMean,lastHessian ] = optimCheck(p, themean, Hessian, lastMean, lastHessian)

if p ~= 0 
     themean = lastMean';
     Hessian = lastHessian;
     fprintf('Optimization failure\n')
 else
     lastMean = themean;
     lastHessian = Hessian;
     
 end


end

