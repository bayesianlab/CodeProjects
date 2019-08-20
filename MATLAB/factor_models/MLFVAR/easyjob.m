function [out ] = easyjob()
tic
out =0;
X = gpuArray(normrnd(0,1,1000,1000));
Y = gpuArray(normrnd(0,1,1000,1000));
for i = 1:100
    out = out + X*Y;
end
toc
    
