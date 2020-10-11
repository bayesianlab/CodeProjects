function [] = chibml(postOutput, blockIndices)

[rows, cols] = size(postOutput);
repeats = length(blockIndices);
thetaStar  = mean(postOutput);


logmvnpdf(thetaStar(blockIndices(1):blockIndices(2)-1)

end

