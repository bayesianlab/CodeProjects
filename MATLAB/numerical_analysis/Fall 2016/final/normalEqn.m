function [ ne] = normalEqn( directions, xTan, xCur, ds)
ne = directions*(xTan - xCur) - ds;
end

