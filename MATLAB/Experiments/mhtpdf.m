function [mvpdf] = mhtpdf(a,b, x12, mu12, Sigma12, nu12, x22, mu22, Sigma22, nu)
conditionalpdf = log(ttpdf(a,b, x12, mu12,Sigma12,nu12));
marginalpdf = logmvtpdf(x22,mu22,Sigma22,nu);
mvpdf  = marginalpdf + conditionalpdf;
end

