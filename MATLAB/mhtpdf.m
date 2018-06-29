function [mvpdf] = mhtpdf(x12, mu12, Sigma12, nu12, x22, mu22, Sigma22, nu)
conditionalpdf = logmvtpdf(x12, mu12,Sigma12,nu12);
marginalpdf = logmvtpdf(x22,mu22,Sigma22,nu);
mvpdf  = marginalpdf + conditionalpdf;
end

