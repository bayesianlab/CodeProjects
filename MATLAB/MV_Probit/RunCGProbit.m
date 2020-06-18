function [] = RunCGProbit(InputFile, OutputFile)
load(InputFile, 'DataCell')
yt = DataCell{1};
X = DataCell{2};

b0= zeros(Q,1);
B0 =100.*eye(Q);
Sims=1000;
bn = 10;
tau0 = 0;
T0 = .5;
s0 = vech(R, -1);
S0 = .5;
R0 = eye(K);

estml =1 ;
[Output]=GeneralMvProbit(yt, X,Sims, bn, cg, estml, b0, B0,  s0, S0, R0);
end

