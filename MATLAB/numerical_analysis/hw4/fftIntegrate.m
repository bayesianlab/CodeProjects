function [ error] = fftIntegrate( fHandle, lowLim, upLim, N, epsilon, visual)

truth = integral(fHandle, lowLim, upLim);
x = linspace(lowLim, upLim, N);
y = fft(fHandle(x));
approx = y(1) * upLim/N;
error = abs(truth - approx);
if error < epsilon
    if visual == 1
    fprintf(['Approximation sufficiently close'... 
        ' \n \t True   %f \n \t Approx %f\n \t Error %f\n'],...
        truth, approx, error)
    end
        
else
    if visual == 1
    fprintf(['Approximation FAILED'... 
        '\n \t True   %f \n \t Approx %f\n \t Error %f\n'],...
        truth, approx, error)
    end
end
end

