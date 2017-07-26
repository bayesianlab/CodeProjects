function [ draws ] = truncNormal( a,b, muj, sigma)
% only works with one sided case
stdevs = (a - muj)/sigma;
if stdevs > 5
%     fprintf('roberts %f, %f, %f\n', stdevs, muj, sigma)
    draws = robertRandVars(stdevs, b, 1, 1);
else
%     fprintf('inverse\n')
    Fa = normcdf( (a-muj)/sigma );
    Fb = normcdf( (b-muj)/sigma);
    draws = norminv(Fa + unifrnd(0,1,1, 1).*(Fb - Fa));
end
draws = muj + sigma*draws;
end