function [retval, accept] = MH(proposal, previousDraw, LogLike,proposalDensity, priorDensity)



Num = LogLike(proposal') + priorDensity(proposal) + proposalDensity(previousDraw);
Den = LogLike(previousDraw') + priorDensity(previousDraw) + proposalDensity(proposal);
alpha = Num - Den;
if log(unifrnd(0,1)) <= alpha
    retval= proposal;
    accept = 1;
else
    retval = previousDraw;
    accept = 0;
end

end

