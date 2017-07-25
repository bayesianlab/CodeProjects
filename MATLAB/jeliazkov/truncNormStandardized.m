function [ draws ] = truncNormStandardized( a,b, N, p )
stdevs = abs(a);
draws = zeros(N,p);
for n = 1:N
    for s = 1:length(stdevs)
        if 0 < a(s)
            if stdevs(s) > 5
            draws(n,s) = robertRandVars(stdevs(s), b(s), 1, 1);
            else
                Fa = normcdf(a(s) );
                Fb = normcdf(b(s));
                draws(n, s) = norminv(Fa + unifrnd(0,1,1, 1).*(Fb - Fa));
            end
        else
            Fa = normcdf(a(s) );
            Fb = normcdf(b(s));
            draws(n, s) = norminv(Fa + unifrnd(0,1,1, 1).*(Fb - Fa));
        end
    end
end
end
