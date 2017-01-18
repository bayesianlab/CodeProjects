function [ xi ] = chebyshevNodes( n )
xi = zeros(n,1);
segment = 0:n;
for i = 1:(n+1)
    xi(i) = cos( ((2*segment(i)+1)/(2*n + 2)) * pi );
end
end

