function [ s ] = testNestedMult( val1, val2)
disp(sprintf(['Nested multiplication: %f\nExact function value:  %f'],...
    val1, val2))
eps = 10^(-4);
if abs(val1 - val2) < eps
    disp(sprintf('Test PASSED\n'))
else
    disp(sprintf('TEST FAILED\n'))
end

