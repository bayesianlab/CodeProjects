function [xt] = packageXt(xt, RestrictionLevel, K)
if RestrictionLevel == 1
    repack = [xt(1:2);1];
    xt = [repack;xt(3:end)];
elseif RestrictionLevel == 2
    repack = [xt(1);1];
    xt = [repack; xt(2:end)];
else
    repack = ones(3,1);
    xt = [repack;xt];
end
xt = reshape(xt, K, 3);

end

