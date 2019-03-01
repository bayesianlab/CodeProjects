function [ backupcell ] = setBackups( InfoCell)

levels = length(InfoCell);
sectors = sum(cellfun(@(x)size(x,1),InfoCell ));
backupcell = cell(sectors,2);

rowplace = 0;
for p = 1:levels
    sectorInfo = InfoCell{1,p};
    nsectors = size(sectorInfo,1);
    
    for k = 1:nsectors
        index = sectorInfo(k,:);
        range = index(1):index(2);
        nrange = length(range);
        backupcell{k+rowplace,1} = zeros(1,length(range));
        backupcell{k+rowplace,2} = eye(nrange);
        
    end
    rowplace = nsectors+rowplace;
end
   
    
end