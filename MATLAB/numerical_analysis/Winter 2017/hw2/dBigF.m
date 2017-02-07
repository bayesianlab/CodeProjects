function [ yt ] = dBigF(dydt, t, y, h )
derivative =  dydt(t(3), y);
[row, ~] = size(derivative);
colOnes = ones(row,1);
yt = colOnes - ((.3333333333333333333*h) * derivative);
end

