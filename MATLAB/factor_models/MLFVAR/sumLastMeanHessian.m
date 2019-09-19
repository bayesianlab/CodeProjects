function [sumbackup] = sumLastMeanHessian(Info, backup, sumbackup)
Regions = size(Info,1);
for r = 1:Regions
    
    lastMean = backup{r,1};
    lastHessian = backup{r,2};
    sumbackup{r,1} = sumbackup{r,1} + lastMean(2:end);
    sumbackup{r,2} = sumbackup{r,2} + lastHessian(2:end,2:end);
    

end
end


