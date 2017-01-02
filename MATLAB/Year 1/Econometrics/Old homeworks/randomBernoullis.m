function [ berns ] = randomBernoullis( n )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
berns = zeros(n,1);
for i = 1:length(berns)
    if unifrnd(0,1) < .5
        berns(i,1) = 1;
    else 
        berns(i,1) = 0;
    end
end

end

