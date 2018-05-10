function [delta, Bt, c] = MaxDelta(delta,y,X,beta, h, lambda,tol,maxits)
for i = 1:maxits   
    [gt, Bt] = OrdinalProbitGradient(delta,y,X,beta,h);
    vt = Bt \ gt; 
    deltaNew = delta + lambda.*vt ;
    fval = sqrt(gt'*gt);
    if fval < tol
       delta = deltaNew;
       c=0;
        break
    elseif i == maxits
        c = 1;
        fprintf("Did not find solution, norm value at max it %d \n", fval);
    else
        delta = deltaNew;
    end
end
end

