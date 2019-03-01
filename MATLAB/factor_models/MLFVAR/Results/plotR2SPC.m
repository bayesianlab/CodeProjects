function [] = plotR2SPC(R2, xaxis, nRegions)

r2new = [R2(:,1:nRegions+1), mean(R2(:,nRegions+2:end),2)];
ncol = size(r2new,2);

hold on 
for k = 1:ncol
    if k == 1
        txt = 'World ';
        pname = txt;
    elseif k <= 1+nRegions
        txt = 'Region ';
        pname = [txt, num2str(k-1)];
    else
        txt = 'Avg. Country ';
        pname =txt;
    end
    
    plot(xaxis, r2new(:,k), 'DisplayName', pname)

end
hold off
legend('show', 'Location', 'southeast')
end