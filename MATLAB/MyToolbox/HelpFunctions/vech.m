function [v] = vech(Matrix, diag)
if diag > 0
    error('diag cannot be greater than 0')
end
v = Matrix(tril(true(size(Matrix)),diag));
end

