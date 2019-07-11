clear;clc;
path = 'TimeBreakSimulations/';
files = dir(join([path,'*.mat']));
x =natsortfiles({files.name});

c = str2double(cell2mat(regexp(x{1}, '[0-9]','match')));
N = floor(length(x)/2);
beg = 1:N;
G = length(beg);
for g = 1:N
    set1 = x{G+ g};
    datapath = join([path,set1]);
    ml1 = load(datapath, 'ml');
    set2 = x{g};
    datapath = join([path,set2]);
    ml2 = load(datapath, 'ml');
    sumMls(g,2) = ml1.ml + ml2.ml;
    sumMls(g,1) = c;
    c = c + 1;
end
hold on
plot(sumMls(:,1), sumMls(:,2))
 plot(100, -1895, 'Marker', '.', 'MarkerSize', 30, 'MarkerFaceColor', 'black')

