function [ imat ] = woodburyWithInverse( inverseMat, B, C)
ceye = eye(size(C,1));
Cinv = C\ceye;
imat = inverseMat - inverseMat*B*((Cinv + B'*inverseMat*B)\ceye)...
    *(B'*inverseMat);
end

