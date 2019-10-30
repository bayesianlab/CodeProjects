function [U] = setGt(InfoCell)
Q = InfoCell{1};
% U = unifrnd(0,1,Q(end,end),length(InfoCell));
U = ones(Q(end,end), length(InfoCell));
for q= 1:length(InfoCell)
    Q = InfoCell{q};
    for g = 1:size(Q,1)
        z = Q(g,:);
        U(z(1),q) = 1;
    end
end
end
