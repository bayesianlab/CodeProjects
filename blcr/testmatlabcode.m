function[] = testmatlabcode()
checkpointdir = '~/CodeProjects/blcr/Checkpoints/';
c = 1;
t = 0;
maxi = 100;
burnin = 3;
if exist(checkpointdir)
    load( join([checkpointdir, 'overwritethis.mat']) )
    fprintf('loaded file')
else
    mkdir(checkpointdir)
end
for k = c:maxi
    pause(.2)
    if mod(k, 5) == 0
        fprintf('saved file')
        c = k;
        save(join( [checkpointdir, 'overwritethis'] ) )
    end
    k
    if k > burnin
        t = t + 1
    end
    
end
t
t/(maxi-3)
rmdir(checkpointdir, 's')
end
