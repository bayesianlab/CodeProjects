function [ new ] = gradientDescent(f, df, guess, step, tol)
i = 0;
new = 0 ;
guess + (step.*df(guess));
while norm(guess-new) > tol
    i = i + 1;
    new = guess + step*df(guess);
    new;
    f(new)
end
end

