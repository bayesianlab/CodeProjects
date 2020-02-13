function [initobsmodel] = setObsModel(initobsmodel, InfoCell)
levels = length(InfoCell);
for k = 1:levels
    t = InfoCell{k};
    sectors = size(t,1);
    for s = 1:sectors
        initobsmodel(t(s, 1), k) = 1;
    end
end


end

