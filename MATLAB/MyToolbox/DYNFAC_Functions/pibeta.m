function [pb] = pibeta(bstar, vecy, vecx, obsModelPrecision,StateObsModel,  StatePrecision, b0,B0inv, T)
nEqns = length(obsModelPrecision);

[~,dimx]=size(vecx);
k = 1:nEqns;
fullpre = diag(obsModelPrecision);
InsideInv = (StatePrecision + kron(eye(T),...
    StateObsModel'* fullpre *StateObsModel))\eye(size(StatePrecision,1));
xpx = zeros(dimx,dimx);
xpy = zeros(dimx,1);
Xz = vecx;
yz = vecy;
for t=1:T
    select = k + (t-1)*nEqns;
    tx = fullpre*vecx(select,:);
    ty = fullpre*vecy(t);
    Xz(select,:)=tx;
    yz(select,:)=ty;
    xpx = xpx + vecx(select,:)'*tx;
    xpy = xpy + vecx(select,:)'*ty;
end
b0 = b0.*ones(1,dimx);
B0inv = eye(dimx).*B0inv;
Xz = kron(eye(T), StateObsModel')*Xz;
yz = kron(eye(T), StateObsModel')*yz;
XzPinv = Xz'*InsideInv;
B = (B0inv + xpx - XzPinv*Xz);
Blowerinv = chol(B,'lower')\eye(dimx);
B = Blowerinv'*Blowerinv;
b = B*(B0inv*b0' + xpy - XzPinv*yz);
pb = logmvnpdf(bstar', b', B);
end
