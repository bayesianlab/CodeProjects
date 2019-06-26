clear;clc;
path = 'TimeBreakSimulations/';
files = dir(join([path,'*.mat']));
x =natsortfiles({files.name});

beg = 1:51;
ends = 52:102;
N = length(beg);
sumMls = zeros(N,2);
c = 75;
for r =1:N
    set1 = x{N + r};
    pathn = join([path,set1]);
    ml1 = load(pathn, 'ml');
    set2 = x{r};
    pathn = join([path,set2]);
    ml2 = load(pathn, 'ml');
    sumMls(r,2) = ml1.ml + ml2.ml;
    sumMls(r,1) = c;
    c = c + 1;
end
[n,m] = max(sumMls(:,2))
sumMls(38,:)
