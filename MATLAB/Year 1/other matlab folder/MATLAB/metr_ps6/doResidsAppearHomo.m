function [  ] = doResidsAppearHomo( covariates, residuals  )
% Do the residuals appear homoskedastic??
[nrows ncols] = size(covariates);
cnt = 0;
cols = [0,0,1;0,1,1;1,0,1];
figure

for i = 2:ncols
    cnt = cnt + 1;
    x = cols(cnt);
    subplot(3,1,cnt)
    scatter(covariates(:,i), residuals, 'filled',...
        'MarkerFaceColor', cols(cnt,:))
    str = sprintf('Residual vs X_%i', cnt);
    title(str)
end
end

