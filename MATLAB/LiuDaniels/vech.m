function [v] = vech(Matrix)
v = Matrix(tril(true(size(Matrix))));
end

