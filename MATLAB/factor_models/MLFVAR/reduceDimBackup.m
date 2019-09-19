function [blank1,blank2] = reduceDimBackup(Info, backup1, backup2)
Regions = size(Info,1);
blank1= backup1;
blank2 = backup2;
for r = 1:Regions
    
    lastMean1 = backup1{r,1};
    lastHessian1 = backup1{r,2};
    lastMean2 = backup2{r,1};
    lastHessian2 = backup2{r,2};
    
    blank1{r,1} = lastMean1(2:end);
    blank1{r,2} = lastHessian1(2:end,2:end);
    blank2{r,1} = lastMean2(2:end);
    blank2{r,2} = lastHessian2(2:end,2:end);
    
end
end

