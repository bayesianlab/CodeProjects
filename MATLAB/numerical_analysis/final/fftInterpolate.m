function [ px, interp ] = fftInterpolate( f_k, N)
betaJ = fft(f_k)/length(f_k);

half = length(f_k)/2;

A0 = betaJ(1);
Am = betaJ(half+1);
An = 2*real(betaJ(2:half));
Bn = -2*imag(betaJ(2:half));

M = 1:length(An);
h = 2*pi/N;
px = (0:N-1).*h;

inner = M'*(px);
lastTerm = length(An)*px;
interp = A0 + (An * cos(inner)) + (Bn * sin(inner)) + (Am * cos(lastTerm));
2*sum(betaJ(half:length(f_k)));
end

