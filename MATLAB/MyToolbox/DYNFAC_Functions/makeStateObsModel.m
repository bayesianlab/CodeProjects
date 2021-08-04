function [StateObsModel] = makeStateObsModel(obsModel, Identities, zerolevel)
levels = length(Identities);
K= size(obsModel,1);
sectorInfo = cellfun(@(x)size(x,2),Identities );
sectors = sum(sectorInfo);


Iden = cell2mat(Identities);
expanded = zeros( K, sectors);
colnum = 0;
for k = 1:levels
    colnum = colnum + sectorInfo(k);
    beg = colnum - sectorInfo(k) + 1;
    if k == zerolevel
        expanded(:, beg:colnum) = repmat(zeros(K,1), 1, sectorInfo(k));
    else
        expanded(:, beg:colnum) = repmat(obsModel(:,k), 1, sectorInfo(k));
    end
end

StateObsModel = expanded.*Iden;

end

