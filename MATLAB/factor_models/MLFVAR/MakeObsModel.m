function [ObsModel] = MakeObsModel(currobsmod, Imat, IndicesInFactor)
levels = size(currobsmod,2);
levelscheck = size(IndicesInFactor,1);
if levels ~= levelscheck
    error('Levels in Current Obs Model not the same as in InfoCell')
end
nFactors= size(Imat,2);
K = size(currobsmod,1);
ObsModel  = zeros(K, nFactors);
for x = 1:levels
    select = IndicesInFactor(x,:);
    indexrange = select(1):select(2);
    ObsModel(:, indexrange ) = Imat(:, indexrange) .* currobsmod(:,x);
end


end

