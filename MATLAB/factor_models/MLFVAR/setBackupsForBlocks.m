function [backupcell] = setBackupsForBlocks(BlockingInfo, identification, restrictions)
levels = length(BlockingInfo);
sectors = sum(cellfun(@(x)size(x,1),BlockingInfo ));
backupcell = cell(sectors,2);
c=0;
for s = 1:levels
    Q = BlockingInfo{s};
    N = size(Q,1);
    
    for n = 1:N
        c = c + 1;
        subsetSelect = Q(n,1):Q(n,2);
        if sum(restrictions(subsetSelect,s)) == 1
            backupcell{c,1} = zeros(1,length(subsetSelect) - 1);
            backupcell{c,2} = eye(length(subsetSelect) - 1);
        else
            backupcell{c,1} = zeros(1,length(subsetSelect) );
            backupcell{c,2} = eye(length(subsetSelect) );
        end
    end
end
end

