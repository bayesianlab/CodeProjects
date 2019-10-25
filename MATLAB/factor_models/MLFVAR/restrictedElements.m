function [U] = restrictedElements(M)
Q = M{1};
NumberOfEquations = Q(end,end);
LevelsColumns = length(M);
U = zeros(NumberOfEquations, LevelsColumns);
for q= 1:length(M)
    Q = M{q};
    for g = 1:size(Q,1)
        z = Q(g,:);
        nz = z(2)-z(1) +1;
        b = zeros(nz,1);
        b(1) = 1;
        U(z(1):z(2),q) = b;
    end
end
end

