function [] = plotR2(R2, xaxis)
[~, ncol] = size(R2)

hold on
for k = 1:ncol
    if k == 1
        txt = 'World ';
        pname = txt;
    else
        txt = 'Region ';
        pname = [txt, num2str(k-1)];
    end    
    plot(xaxis,R2(:,k),'DisplayName', pname)
end
hold off
legend('show', 'Location', 'southeast')
end

