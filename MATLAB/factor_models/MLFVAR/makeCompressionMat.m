function [compressmat] = makeCompressionMat(Isom)

[K, q] = size(Isom);
compressmat = kron(eye(K), ones(1,q)) .* repmat(Isom, 1,K);
compressmat= sparse(compressmat);
end

