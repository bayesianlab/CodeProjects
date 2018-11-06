function [draw] = mhRegion(ydemu, obsVariance, currobsmod, mu, Hessian,...
    StateVariable, StateVariance, IOregion, IOcountry, K, T)
% First element positve

df = 15;
PriorMean =  zeros(K,1);
PriorVariance =  100.*eye(K);
zerovec = zeros(K*T,1);
w1 = sqrt(chi2rnd(df,1)/df);
StateObsModel = [currobsmod(:,1), IOregion .* currobsmod(:,2), IOcountry .* currobsmod(:,3)];
sparseEye = speye(T);
kronobsmod = kron(sparseEye, StateObsModel);
obsvardiag = spdiags(repmat(obsVariance,T,1), 0, T*K, T*K);
% ss = StateObsModel*StateVariable;
Precision = Hessian\eye(size(Hessian,1));
likevarianceden = kronobsmod*StateVariance*kronobsmod'+ obsvardiag;

% draw restricted candidate
sigma = sqrt(Hessian(1,1));
restricteddraw = truncNormalRand(0, Inf, mu(1), sigma)/w1;

% draw conditional candidate
[cdraw,condmean,condvar] = kowConditionalDraw(mu(2:end), Precision(2:end,2:end),...
    Precision(2:end, 1), Precision(1,1), restricteddraw, mu(1), df, df+1);
candidate = [restricteddraw;cdraw];
StateObsModel = [currobsmod(:,1), IOregion .* candidate, IOcountry .* currobsmod(:,3)];
% ss = StateObsModel*StateVariable;
kronobsmod = kron(speye(T), StateObsModel);
likevariancenum = kronobsmod*StateVariance*kronobsmod' + obsvardiag;


% Mh step
LIKE  = log(mvnpdf(candidate,PriorMean, PriorVariance)) + ...
    log(mvnpdf(ydemu, zerovec, likevariancenum));
PROP = log(ttpdf(0,Inf,mu(1), sigma,df, currobsmod(1,2))) + ...
    mvstudenttpdf(currobsmod(2:end,2), condmean, condvar, df);
Num = LIKE + PROP

LIKE 

LIKE  = log(mvnpdf(currobsmod(:,2),PriorMean,PriorVariance))+ ...
          log(mvnpdf(ydemu, zerovec, likevarianceden));
PROP = log(ttpdf(0,Inf,mu(1), sigma,df, restricteddraw)) + ...
    mvstudenttpdf(cdraw, condmean, condvar, df);

LIKE

Den = LIKE + PROP;
if log(unifrnd(0,1,1)) <= Num - Den
    fprintf('accept\n')
    draw = candidate;
else
    draw = currobsmod(:,2);
end
end

