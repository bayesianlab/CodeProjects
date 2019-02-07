function[] =  DisplayHelpfulInfo(K,T,Regions,Countries,SeriesPerCountry, nFactors, wb, Sims, burnin, ReducedRuns)
fprintf('\nThis simulation is running wtih the following settings:\n')

fprintf('\tK = %i dimenstional system\n', K)
fprintf('\tt = %i timeperiods \n',  T)
fprintf('\tC = %i  countries\n', Countries)
fprintf('\tn = %i SeriesPerCountry \n',  SeriesPerCountry)
fprintf('\tR = %i  Regions\n',  Regions)
fprintf('\tq = %i  factors is the total number of factors\n',  nFactors)
fprintf('The world observation model is blocked into\n')
fprintf('\tb = %i blocks\n', wb)
blockSize = K/wb;
if floor(blockSize) ~= blockSize
    error('Invalid wb size')
end
fprintf('\tj = %i is the number of equations per block\n', blockSize) 
fprintf('MCMC Info:\n')

fprintf('\tM = %i are the total MCMC runs\n', Sims)
fprintf('\tg = %i is the Burnin Period\n', burnin)
fprintf('\tr = %i number of Reduced Runs (Chibs 1995 Method)\n\n', ReducedRuns)
fprintf('This is an extension of Kose, Otrok & Whitemans 2003 paper\n adapting Chan & Jeliazkovs 2009 method.')
fprintf('\n\n')
end
