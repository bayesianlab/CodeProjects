function [ wood ] = woodburyInvert( A,B,C,D)
Ainv = A\eye(size(A,1));
Middle = ( C\eye(size(C,1)) + D*(Ainv*B));
Middleinv = Middle\eye(size(Middle,1));
wood = Ainv - (Ainv * B) * Middleinv * (D * Ainv);
end

