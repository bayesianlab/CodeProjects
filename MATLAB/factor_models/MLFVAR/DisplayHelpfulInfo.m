function[] =  DisplayHelpfulInfo(K,T,Regions,Countries,SeriesPerCountry, nFactors, wb, Sims, burnin, ReducedRuns, options)
fprintf('\n<strong> This simulation is running wtih the following settings: </strong>\n')

fprintf('\tK = %i dimenstional system\n', K)
fprintf('\tt = %i timeperiods \n',  T)
fprintf('\tC = %i  countries\n', Countries)
fprintf('\tn = %i SeriesPerCountry \n',  SeriesPerCountry)
fprintf('\tR = %i  Regions\n',  Regions)
fprintf('\tq = %i  factors is the total number of factors\n',  nFactors)
fprintf('<strong> The world observation model is blocked into: </strong>\n')
fprintf('\tb = %i blocks\n', wb)
blockSize = K/wb;
if floor(blockSize) ~= blockSize
    error('Invalid wb size')
end
fprintf('\tj = %i is the number of equations per block\n', blockSize) 
fprintf('<strong> MCMC Info:</strong>\n')

fprintf('\tM = %i are the total MCMC runs\n', Sims)
fprintf('\tg = %i is the Burnin Period\n', burnin)
fprintf('\tr = %i number of Reduced Runs (Chibs 1995 Method)\n\n', ReducedRuns)
fprintf('<strong>Optimization Settings:</strong>\n')
disp(options)
fprintf('<strong>This is an extension of Kose, Otrok & Whitemans 2003 paper\n adapting Chan & Jeliazkovs 2009 method.</strong>')
fprintf('\n\n')
end
