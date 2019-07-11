function[] =  DispInfo(K,T,nFactors, Sims, burnin, ReducedRuns)
fprintf('\nThis simulation is running wtih the following settings:\n')

fprintf('\tK = %i dimenstional system\n', K)
fprintf('\tT = %i timeperiods \n',  T)

fprintf('\tq = %i  factors is the total number of factors\n',  nFactors)


fprintf('\tM = %i are the total MCMC runs\n', Sims)
fprintf('\tg = %i is the Burnin Period\n', burnin)
fprintf('\tr = %i number of Reduced Runs (Chibs 1995 Method)\n\n', ReducedRuns)
fprintf('This is an extension of Kose, Otrok & Whitemans 2003 paper\n adapting Chan & Jeliazkovs 2009 method.')
fprintf('\n\n')
end