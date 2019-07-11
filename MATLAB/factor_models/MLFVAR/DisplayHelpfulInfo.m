function[] =  DisplayHelpfulInfo(K,T,nFactors,  Sims, burnin, ReducedRuns, options)
fprintf('\n<strong> This simulation is running wtih the following settings: </strong>\n')

fprintf('\tK = %i dimenstional system\n', K)
fprintf('\tt = %i timeperiods \n',  T)
fprintf('\tq = %i  factors is the total number of factors\n',  nFactors)
fprintf('<strong> MCMC Info:</strong>\n')

fprintf('\tM = %i are the total MCMC runs\n', Sims)
fprintf('\tg = %i is the Burnin Period\n', burnin)
fprintf('\tr = %i number of Reduced Runs (Chibs 1995 Method)\n\n', ReducedRuns)
fprintf('<strong>Optimization Settings:</strong>\n')
disp(options)
fprintf('<strong>This is an extension of Kose, Otrok & Whitemans 2003 paper\n adapting Chan & Jeliazkovs 2009 method.</strong>')
fprintf('\n\n')
end
