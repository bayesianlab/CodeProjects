% test
clc
sims = 100;
gl = 0;

mu = 1;
ss = 2;
for i = 1:sims
    u = unifrnd(0,1);
    t1 = truncatedNormal(mu, ss, u, 0,1);
    if t1 < 0 || t1 > 1
        disp('TEST FAILED')
        break
    end
    u = unifrnd(0,1);
    t2 = truncatedNormal(mu, ss, u, 1,Inf)
    if t2 < 1
        disp('TEST FAILED')
        break
    end
end
    