function [v] = vech(Matrix, diag)
v = Matrix(tril(true(size(Matrix)),diag));
end

