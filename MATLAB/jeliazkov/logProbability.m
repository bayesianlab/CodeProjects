function [ lp ] = logProbability( sims, simResults)
maxSim = max(simResults);
if abs(maxSim) < 1e-14
    lp = 1;
    return
end
weight = (1/(sims*maxSim));
lp = log(weight*sum(simResults)*maxSim);
end

