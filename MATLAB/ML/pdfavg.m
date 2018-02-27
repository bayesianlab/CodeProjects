function [realml] = pdfavg(logpdf)
maxval = max(logpdf);
realml = log(mean(exp(logpdf - maxval))) + maxval;
end

