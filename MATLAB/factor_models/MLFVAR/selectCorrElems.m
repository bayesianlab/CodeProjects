function [U] = selectCorrElems(D, squares)
b = length(squares);
U = zeros(b, b);
for u = 1:b
    U(u,u) = D(squares(u),squares(u));
    for v = u:b
        U(u,v) = D(squares(u),squares(v) );
    end
end

U = U + U';
end