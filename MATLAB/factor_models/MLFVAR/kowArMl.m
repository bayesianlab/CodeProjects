function [ pistar ] = kowArMl(StateTransitionMat, ThetaStar,StateVariables )
[Rows,Arp,D] = size(StateTransitionMat);
alphagtostar = zeros(D,1);
alphastartoj = zeros(D,1);
pistar = zeros(Rows,1);
R = [1;zeros(Arp-1,1)];
RRp = R*R';
bottom = [eye(Arp-1),zeros(Arp-1,1)];
eyelagsquared = eye(Arp^2);
zeroarp = zeros(1,Arp);
for j = 1:Rows
    thetag = StateTransitionMat(j,:,:);
    thetastar = ThetaStar(j,:);
    State = StateVariables(j,:);
    [y,x] = kowLagStates(State, Arp);
    Phi = [thetastar;bottom];
    P0star = reshape((eyelagsquared  - kron(Phi,Phi))\RRp(:), Arp,Arp);
    for i = 1:D
        % Numerator of CJ 2001
        [~,~,~,gammahat, Ghat] = kowArPropose(y,x,thetag(i));
        eyelagsquared = eye(Arp^2);
        Phi = [StateTransitionMat(j,:,i);bottom];
        P0g = reshape((eyelagsquared  - kron(Phi,Phi))\RRp(:), Arp,Arp);
        den = logmvnpdf(State(1:Arp), zeroarp, P0g);
        num = logmvnpdf(State(1:Arp), zeroarp, P0star);
        q = logmvnpdf(thetastar, gammahat, Ghat);
        alphagtostar(i) = min(0, num-den) + q;
        % Denominator of CJ 2001
        [~,P0j, ~, ~, ~] = kowArPropose(y,x,thetastar);
        num = logmvnpdf(State(1:Arp), zeroarp, P0j);
        den = logmvnpdf(State(1:Arp), zeroarp, P0star);
        alphastartoj(i) = min(0,num-den);
    end
    pistar(j) = logAvg(alphagtostar') - logAvg(alphastartoj');
end
end

