p = [.2,.1,.02; .5,.25,.05];
s = [1,1]'
[P0,~,~,x] = initCovar(p, s)

full(FactorPrecision(p, P0, [1,1]', 4))