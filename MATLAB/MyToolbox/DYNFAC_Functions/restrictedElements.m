function [U] = restrictedElements(M)
%% Returns a matrix with 1 being the 
% restricted loading using the identification restriction 
% scheme given in CJ 2009, ones for each group of 
% factors
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

for m = 1:length(M)
    u = M{m};
    if u > 1
        zeroindexs = 1:(u(1)-1);
        U(zeroindexs,m) = -1;
    end
end

