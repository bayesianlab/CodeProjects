function [U] = setGt(M)
Q = M{1};
U = unifrnd(0,1,Q(end,end),length(M));
for q= 1:length(M)
    Q = M{q};
    for g = 1:size(Q,1)
        z = Q(g,:);
        U(z(1),q) = 1;
    end
end
end
