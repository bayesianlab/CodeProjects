load('realdata_27_Sep_2018_13_53_02.mat');
postbx = postb(1001:10000,:);
betausa = bbar(1:4);
betacan = bbar(5:8);
yusa = y(1,:);
xusainRecession = xusa(yusa > 0, :);
ycan = y(2,:);
xcaninRecession = xusa(ycan > 0, :);

marginal = mean(normcdf(xusainRecession*betausa'));
marginalcan = mean(normcdf(xcaninRecession*betacan'));
[eqns, obs] = size(y);
IndexInRecession = sum(y,1) == 2;
XusAndCanInRecession = [kron(xusa(IndexInRecession, :), [1,0]'),...
    kron(xcanada(IndexInRecession, :), [0,1]')];
yuscanRecession = y(:, IndexInRecession);
[eqns, obsInRecession]= size(yuscanRecession);

muInrecession = reshape(XusAndCanInRecession*bbar', eqns,obsInRecession);
sims=100;
burnin = 10;
joint = mean(exp(computeOrthantProb(yuscanRecession,muInrecession,...
    r0,sims,burnin)));


probCanadaConditionalUS = joint/marginal
probUsCondionalCanada = joint/marginalcan



