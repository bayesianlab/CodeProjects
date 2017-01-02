clear;
clc;

options = optimset('Display', 'off', 'MaxIter', 15e3, 'TolX',1e-4,'Tolfun',1e-4);
options.LargeScale = 'off';

betas = [ .67; -1.75];
lbet = length(betas);
Ai = [.5];
lai = length(Ai);
N = 500;
choices = 5;
sims = 100;
simSim = length(Ai);
bGuess = zeros(length(betas),1);

stoBetasSubsampled = zeros(lbet, sims);
stoSeSubsampled = zeros(lbet, sims);
stoBetasUnconstrained = zeros(lbet, sims);
stoSeUnconsrained = zeros(lbet, sims);

stoMeansSub = zeros(lai, lbet);
stoSeSub = zeros(lai, lbet);
stoMeansUnc = zeros(lai, lbet);
stoSeUnc = zeros(lai, lbet);

for j = 1:simSim
    tic
    ai = Ai(j);
    for i = 1:sims
        
        X = normrnd(0, 1, lbet, choices, N);
        Y = choice_data(betas, X, choices, N);
        subX = makeSubSampleData(Y, X, ai);
        [eu, ~,~,~,~,hu] = fminunc('condlogit', bGuess, options, Y, X, 0);
        [es, ~,~,~,~, hs]= fminunc('condlogit', bGuess, options, Y, X,...
            1, subX);
        stoBetasSubsampled(:,i) = eu;
        stoSeSubsampled(:,i) = sqrt(diag(inv(hs)));
        stoBetasUnconstrained(:,i) = es;
        stoSeUnconsrained(:,i) = sqrt(diag(inv(hu)));
        nl = sprintf('\n');
    if mod(i,10) == 0  || i == 1
        disp(['Inner loop iterations left: ', num2str(sims - i)]);
        disp(nl)
    end
    end
    stoMeansSub(j, :) = mean(stoBetasSubsampled');
    stoSeSub(j,:) = nanmean(stoSeSubsampled');
    stoMeansUnc(j, :) = mean(stoBetasUnconstrained');
    stoSeUnc(j,:) = nanmean(stoSeUnconsrained');
    
    itsleft = simSim - j;
    tRemains = itsleft*toc;
    disp(['Iterations left: ', num2str(itsleft)]);
    disp(['Estimated time left: ', num2str(tRemains)]);
    disp(nl);
end
stoMeansSub
stoSeSub
stoMeansUnc
stoSeUnc
