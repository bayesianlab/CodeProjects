function [Minn, SigmaU] = EqnBEqnMinnesotaPrior(yt, xt, p, lambda0, lambda1, theta)
[~, K] = size(yt);
M = xt*inv(xt'*xt)*xt';
[rm, cm] = size(M);
P = eye(rm, cm) - M;
SigmaU = yt'*P*yt./rm;
[sr, ~] = size(SigmaU);
LambdaTheta = lambda1*theta*ones(sr);
LambdaTheta(logical(eye(sr))) = lambda1;
LagVec = (1:p).^(-1);
SigmaMat = sqrt(diag(SigmaU)).*ones(sr);
SigmaMat = SigmaMat .* (SigmaMat').^(-1);
MinnP= [lambda0.*ones(sr, 1),...
    kron(ones(1,p), SigmaMat).*kron(LagVec, LambdaTheta)];
MinnP = MinnP .* MinnP;
[mr, ~] = size(MinnP);
Minn = zeros(K*p + 1, K*p + 1, K);
for i = 1:mr
    Minn(:,:,i) = diag(MinnP(i,:));
end
end

