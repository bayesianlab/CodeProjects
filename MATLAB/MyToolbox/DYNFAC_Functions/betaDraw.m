function [bupdate, xbt, b, B] = betaDraw(vecy, SurX, obsModelPrecision,...
    StateObsModel, StatePrecision, b0,B0inv, T)
nEqns = length(obsModelPrecision);
nFactors = size(StateObsModel,2);
[~,pK]=size(SurX);
k1 = 1:nEqns;
k2= 1:nFactors;
fullpre = diag(obsModelPrecision);
Pinv = (StatePrecision + kron(eye(T),...
    StateObsModel'* fullpre *StateObsModel))\eye(size(StatePrecision,1));
xpx = zeros(pK,pK);
xpy = zeros(pK,1);
Xzz = zeros(T*nFactors,pK);
yzz = zeros(T*nFactors, 1);

b0 = b0.*ones(1,pK);
B0inv = eye(pK).*B0inv;
for t=1:T
    select1 = k1 + (t-1)*nEqns;
    select2 = k2 + (t-1)*nFactors;
    tx = fullpre*SurX(select1,:);
    ty = fullpre*vecy(select1);
    Xzz(select2,:) = StateObsModel'*tx;
    yzz(select2,:) = StateObsModel'*ty;
    xpx = xpx + SurX(select1,:)'*tx;
    xpy = xpy + SurX(select1,:)'*ty;
end
XzzPinv = Xzz'*Pinv;
B = (B0inv + xpx - XzzPinv*Xzz);
Blowerinv = chol(B,'lower')\eye(pK);
B = Blowerinv'*Blowerinv;
b = B*(B0inv*b0' + xpy - XzzPinv*yzz);
b
bupdate = b + Blowerinv'*normrnd(0,1,pK,1);

xbt = SurX*bupdate;
end

