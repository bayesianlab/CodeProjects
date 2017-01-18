clear
clc
n = [5,10,15,20];
x = .5;
for i = 1:length(n)
    approx = 1;
    for j = 1:n(i)
        approx = approx + (x^j)/factorial(j);
    end
    disp(sprintf('terms %i', n(i)))
    error = exp(.5) - approx
end