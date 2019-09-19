function [Q] = orthog(ColumnMatrix)

% Orthogonalize only
[r,c] = size(ColumnMatrix);
R = zeros(c,c);
Q = zeros(r,c);
norms = vecnorm(ColumnMatrix,2);
for h = 1:c
    v = ColumnMatrix(:,h);
    for b = 1:h-1
        R(b,h) = Q(:,b)'*ColumnMatrix(:,h);
        v = v - R(b,h)*Q(:,b);
    end
    R(h,h) = norm(v);
    Q(:,h) = v/R(h,h);
end
Q = sqrt(norms).*Q;
end

