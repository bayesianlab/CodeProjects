function [ passFail ] = test_dividedDifferences( outputVal, expectedVal )
passFail = 0;
if isnumeric(outputVal)
    if isrow(expectedVal)
        expectedVal = expectedVal';
    end
    space = norm( outputVal - expectedVal);
    eps = 10^-4;
    if space < eps
        disp([outputVal, expectedVal])
        disp(sprintf('Test passed.\n'))
        passFail = 1;
    else
        disp([outputVal, expectedVal])
        disp(sprintf('Test FAILED.\n'))
        passFail = 0;
    end
end
end

