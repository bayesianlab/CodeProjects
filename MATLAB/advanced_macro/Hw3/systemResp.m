function [ yNext ] = systemResp( F,G,shock, periods )
[r,c] = size(F);
[rs, cs] = size(shock)
shockE = zeros(rs,cs);
yNext = zeros(c, periods);
yNext = zeros(c, periods);
yEqm = zeros(c,periods);
for i = 1:periods
    if i == 1
        yNext(:,i + 1) = F*yNext(:,i) + G*shock;
        yEqm(:, i+ 1) = F*yEqm(:, i) + G*shockE;
        shock = 0;
    else
       yNext(:,i + 1) = F*yNext(:,i);
       yEqm(:, i+ 1) = F*yEqm(:, i);
    end
end
yNext = yNext - yEqm;
end

