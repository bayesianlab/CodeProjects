function [R2] = computeR2(y,x)
fitted =  (1./sum(x.^2,2)).*sum((x.*y),2).* x;
SST = sum((y - mean(y,2)).^2,2);
SSR = sum((y - fitted).^2,2) ;
R2 = (1-(SSR./SST))';
end

