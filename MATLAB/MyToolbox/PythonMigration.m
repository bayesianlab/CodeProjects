clear;clc;


ydata = import_python_data("/home/dillon/CodeProjects/Python/MultilevelModel/y_data.csv", [2, Inf]);
xdata = import_python_data("/home/dillon/CodeProjects/Python/MultilevelModel/x_data.csv", [2, Inf]);
fdata = import_python_data("/home/dillon/CodeProjects/Python/MultilevelModel/f_data.csv", [2, Inf]);
xdata = xdata(:,1:3);

[K,T]= size(ydata);
InfoCell = {[1,K], [1,6; 7,9]};
Id = MakeObsModelIdentity(InfoCell);
nFactors = sum(cellfun(@(x)size(x,2),Id));
A = makeStateObsModel(ones(K,nFactors), Id, 0);

gammas = repmat([.2,.2], 3,1);
P0 = initCovar(gammas, ones(1,nFactors));
factorPrecision = ones(nFactors,1);
FP = FactorPrecision(gammas, P0, factorPrecision, T);

surX = surForm(xdata, K);
KP = size(surX,2);
b0 = zeros(KP,1);
B0inv = (1./100).*eye(KP);
% betaDraw(ydata(:), surForm(xdata,K), ones(K,1), A, FP, b0', B0inv, T) 

A = ones(9,3);
A(7:end,2) = 0;
A(1:6,3) = 0;
Xbeta= reshape(surX*ones(KP,1), K,T);
resids = ydata - Xbeta - A*fdata;
fdata

sum(resids.*resids,2)


qd(20002, 19401, -605.7,0,1)




% r = @(x) .5* ( 100*((x(2) - x(1))^2) + ((1 - x(1))^2));
% 
% options = optimoptions('fminunc', 'Display', 'off', 'OptimalityTolerance', 1e-6) 
% tic
% [x,~,~,~,~,h]= fminunc(r, [-1.9,2], options)
% toc

logmvnpdf([0,0, 0], [.5,.5, 1], .5*eye(3))

full(stateSpaceIt([.2,.2],2))

A = [2,-1;-1,3]
b = [1,2;3,1]
A\b

[P0, ~,~,nv] = initCovar([.2,.2], 1)

full(FactorPrecision([.2,.2, .2, .2], initCovar([.2,.2, .2, .2], 1), [1], 10))
full(FactorPrecision([.2,.2]', initCovar([.2,.2]', [1,1]), [1,1]', 10))
full(FactorPrecision([.2,.2;.3,.3], initCovar([.2,.2;.3,.3], [1,1]), [1,1]', 10))


