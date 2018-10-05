function [ dF,B  ] = maxsig( zdemean, D, R )
Sig = D*R*D;
J = size(R,1);
N=length(zdemean);
iSig = Sig\eye(J);
zhat = D*zdemean;
addup = 0;
deriv = zeros(J*J,N);
vecSigCount = 0;
for j = 1:J
    for k = 1:J
        vecSigCount = vecSigCount + 1;
        dSigdsigi = zeros(J);
        dSigdsigi(k,j) = 1;
        for i = 1:N
            W = zhat(:,i)'*iSig;
            addup = addup + W*dSigdsigi*W';
            deriv(vecSigCount,i) = addup - trace(iSig*dSigdsigi);
        end
    end
end
dF = sum(deriv,2)./N;
B = zeros(J*J);
for i = 1:N
    B = B + deriv(:,i)*deriv(:,i)';
end
B= B./N;
