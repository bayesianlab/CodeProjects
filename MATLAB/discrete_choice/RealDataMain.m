clear;clc;
probit_realdata_import
y = table2array(internationalprobitdataset(:,8:9))';
xusa = table2array(internationalprobitdataset(:,2:4));
xcanada = table2array(internationalprobitdataset(:,5:7));
[r,c] = size(xusa);
K = 2;
wishartDf = 50;
X = [kron(xusa,[1,0]'),kron(xcanada,[0,1]')];

W0 = wishrnd(eye(K), wishartDf)./wishartDf;
D0 = diag(W0);
R0 = diag(D0.^(-.5))*W0*diag(D0.^(-.5));
[bbar, r0, ar] = mv_probit(y, X, zeros(c*2,1), eye(c*2), wishartDf, diag(D0), R0 , 10);

 
fileID = fopen('SimulationStudyMvProbitResults.txt' ,'w');
fprintf(fileID, 'bbar\n');
fprintf(fileID,'%f\n', bbar');
fprintf(fileID, '\n');
fprintf(fileID, 'r0 = \n');
for i = 1:size(r0,1)
    for j = 1:size(r0,2)
        fprintf(fileID, '%f ', r0(i,j));
    end
    fprintf(fileID, '\n');
end
fprintf(fileID, '\n');
fprintf(fileID, 'ar \n');
fprintf(fileID, '%f\n', ar);
fclose(fileID);

[bbar, r0, ar] = mv_probit_new_proposal(y, X, zeros(c*2,1), eye(c*2), wishartDf, diag(D0), R0 , 10);

fileID = fopen('SimulationStudyMvProbitNewProposalResults.txt' ,'w');
fprintf(fileID, 'bbar\n');
fprintf(fileID,'%f\n', bbar');
fprintf(fileID, '\n');
fprintf(fileID, 'r0 = \n');
for i = 1:size(r0,1)
    for j = 1:size(r0,2)
        fprintf(fileID, '%f ', r0(i,j));
    end
    fprintf(fileID, '\n');
end
fprintf(fileID, '\n');
fprintf(fileID, 'ar \n');
fprintf(fileID, '%f\n', ar);
fclose(fileID);