clear;clc;
rng(1)
u=1:6
mean(u)
av =0;
for n = 1:6
    av = (av*(n-1) + u(n))/n
end
av