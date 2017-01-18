function [ passFail ] = test_evalPoints( outVector, correctVector )

if isnumeric(outVector)
    if isrow(correctVector)
        correctVector = correctVector';
    end
    space = norm(outVector - correctVector);
    eps = 10^-4;
    if space < eps
        disp(sprintf('evalPoints Test passed.\n'))
        disp('evalPoints Correct Values')
        disp([outVector correctVector])
        disp('%%%%%%%%%%%%%%%%%%%%%%%%')
        passFail = 1;

    else
        disp(sprintf('evalPoints TEST FAILED.\n'))
        disp('evalPoints Correct Values')
        disp([outVector correctVector])
        disp('%%%%%%%%%%%%%%%%%%%%%%%%')
        passFail = 0;
    end
else
    if outVector == correctVector      
        disp(outVector)
        disp(correctVector) 
        disp(sprintf('Test passed. Error expected.\n'))
        disp('%%%%%%%%%%%%%%%%%%%%%%%%')
        passFail = 1;
    else
        disp(outVector)
        disp(correctVector) 
        disp(sprintf('TEST FAILED\n'))
        disp('%%%%%%%%%%%%%%%%%%%%%%%%')
        passfail = 0;
    end
end
end 
