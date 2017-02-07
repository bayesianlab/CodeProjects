function [ val ] = bigF(t, yNew, yOld, fnq, h )
diffY = yNew  - yOld(1,:);
F_Y = -(.333333333333333333333 * h) *(fnq(t(1), yOld(1, :)) +...
    4 * fnq(t(2), yOld(2, :)) + fnq(t(3), yNew)); 
val = diffY' + F_Y;
end

