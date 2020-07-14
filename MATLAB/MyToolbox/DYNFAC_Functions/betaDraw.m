function [bupdate, xbt, b, B] = betaDraw(vecy, vecx, obsModelPrecision,StateObsModel,  StatePrecision, b0,B0inv, T)
nEqns = length(obsModelPrecision);
nFactors = size(StateObsModel,2);
[rowx,dimx]=size(vecx);
k1 = 1:nEqns;
k2= 1:nFactors;
fullpre = diag(obsModelPrecision);
InsideInv = (StatePrecision + kron(eye(T),...
    StateObsModel'* fullpre *StateObsModel))\eye(size(StatePrecision,1));
xpx = zeros(dimx,dimx);
xpy = zeros(dimx,1);
Xzz = zeros(rowx*nFactors,dimx);
yzz = zeros(size(vecy,1)*nFactors, 1);


for t=1:T
    select1 = k1 + (t-1)*nEqns;
    select2 = k2 + (t-1)*nFactors;
    tx = fullpre*vecx(select1,:);
    ty = fullpre*vecy(t);
    Xzz(select2,:) = StateObsModel'*tx;
    yzz(select2,:) = StateObsModel'*ty;
    xpx = xpx + vecx(select1,:)'*tx;
    xpy = xpy + vecx(select1,:)'*ty;
end

XzzPinv = Xzz'*InsideInv;
B = (B0inv + xpx - XzzPinv*Xzz);
Blowerinv = chol(B,'lower')\eye(dimx);
B = Blowerinv'*Blowerinv;
b = B*(B0inv*b0' + xpy - XzzPinv*yzz);
bupdate = b + Blowerinv'*normrnd(0,1,dimx,1);
xbt = vecx*bupdate;
end

