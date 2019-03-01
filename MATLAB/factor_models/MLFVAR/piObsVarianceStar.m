function [v] = piObsVarianceStar(varianceStar, conditionalParam1, conditionalParam2Mat)
v = logAvg( logigampdf(varianceStar, conditionalParam1, conditionalParam2Mat));
end

