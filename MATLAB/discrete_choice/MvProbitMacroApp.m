function [  ] = MvProbitMacroApp( Sims)
if ischar(Sims)
    Sims = str2num(Sims);
end
probit_realdata_import
[r,~] = size(internationalprobitdataset);
y = table2array(internationalprobitdataset(:,8:9))';
constant = ones(r,1);
xusa = [constant, table2array(internationalprobitdataset(:,2:4))];
xcanada = [constant, table2array(internationalprobitdataset(:,5:7))];
[r,c] = size(xusa);
K = 2;
wishartDf = 50;
X = [kron(xusa,[1,0]'),kron(xcanada,[0,1]')];
W0 = wishrnd(eye(K), wishartDf)./wishartDf;
D0 = diag(W0);
R0 = diag(D0.^(-.5))*W0*diag(D0.^(-.5));
b0 = zeros(c*2,1);
B0 = eye(c*2);
track = [1,2;2,1];
[bbar, r0, ar, postr0, ~, postb] = mv_probit(y, X, b0, B0, wishartDf,...
    diag(D0), R0 , Sims, track);
fname = 'realdata_';
name = createDateString(fname);
save(name)
 
end

