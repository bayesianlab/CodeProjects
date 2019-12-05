% clear;clc;
% savepath = '~/GoogleDrive/statespace/';
% simpath = 'tbk_results/';
% files = dir(join([simpath,'*.mat']));
% x =natsortfiles({files.name});
% c = str2double(cell2mat(regexp(x{1}, '[0-9]','match')));
% N = floor(length(x)/2);
% beg = 1:N;
% c = str2double(cell2mat(regexp(x{1}, '[0-9]','match')));
% N = floor(length(x)/2);
% beg = 1:N;
% G = length(beg);
% 
% for g = 1:N
%     set1 = x{G+ g}
%     datapath = join([simpath,set1]);
%     ml1 = load(datapath, 'ml');
%     set2 = x{g}
%     datapath = join([simpath,set2]);
%     ml2 = load(datapath, 'ml');
%     sumMls(g,2) = ml1.ml + ml2.ml;
%     sumMls(g,1) = c;
%     c = c + 1;
% end
% 
% [a, b] = max(sumMls(:,2));
% tbaxis = 1976:2000;
% subSumMls = sumMls(11:35,:);
% mlfull = load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/BigKowResults/Old/Result_kowz.mat', 'ml');
% mlfull = mlfull.ml;
% hold on 
% tbp = plot(tbaxis, ones(length(tbaxis),1).*mlfull, 'black');
% plot(tbaxis, subSumMls(:,2),'red')
% saveas(tbp, join([savepath,'tbp.jpeg']))
% Max occurs at End 25 Beg 26
% load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/tbk_results/Result_TimeBreakKowEnd25.mat')
% csvwrite('vdend', varianceDecomp)
% load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/tbk_results/Result_TimeBreakKowBeg26.mat')
% csvwrite('vdbeg', varianceDecomp)
% plot(varianceDecomp(1:3:180,2), '.')
% load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/tbk_results/Result_TimeBreakKowEnd25.mat')

vd = zeros(K,3) ;
vareps = var(reshape(Xt*sumBeta,K,T), [],2);
facCount = 1;
for k = 1:3
    Info = InfoCell{1,k};
    Regions = size(Info,1);
    for r = 1:Regions
        subsetSelect = Info(r,1):Info(r,2);
        vd(subsetSelect,k) = var(sumOM(subsetSelect,k).*sumFt(facCount,:),[],2);
        facCount = facCount + 1;
    end
end
varianceDecomp = [vareps,vd];
varianceDecomp = varianceDecomp./sum(varianceDecomp,2);
csvwrite('varianceDecompEnd.csv', varianceDecomp)



csvwrite('sumOM.csv', sumOM)

% load('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/tbk_results/Result_TimeBreakKowBeg26.mat')
