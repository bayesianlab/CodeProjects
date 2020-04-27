function [level] = LevelCovid(RawData, TransformedYt)
logcoviddata = log(RawData+1);
coviddiffdata = diff(logcoviddata,1,2);
mus = mean(coviddiffdata,2);
sigmas = std(coviddiffdata,[],2);
level = (RawData(:,3:end) .* exp((sigmas.*TransformedYt + mus))) -1; 
end

