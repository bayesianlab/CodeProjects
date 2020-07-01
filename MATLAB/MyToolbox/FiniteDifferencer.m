function [g] = FiniteDifferencer(guess, Function, type)
N = size(guess,1);
IN = eye(N);
g = zeros(N,1);
if type == 1
    h = sqrt(eps);
    Fn = Function(guess);
    for n = 1:N
        q =IN(:,n).*h;
        g(n) = (Function(guess+q) - Fn)/h;
    end
elseif type == 2
    h = 2*sqrt(eps);
    for n = 1:N
        q =IN(:,n).*h;
        g(n) = (Function(guess+q) - Function(guess-q))/h;
    end
end
end

