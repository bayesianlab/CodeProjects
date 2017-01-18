function [ total  ] = fftInterpolate( f_k)
betaJ = fft(f_k)/N;

real(betaJ);
imag(betaJ);
A0 = fy1(1);
AM = fy1(half+1);
An = 2*real(fy1(2:half));
Bn = -2*imag(fy1(2:half));

N2 = 2^3;
M = 1:length(An);
k2 = 0:N2-1;
px = (0:.1:2*pi);
% inner = kron(2*pi*M', px);
inner = M'*(px);
lastTerm = length(An)*px;
interp = A0 + (An * cos(inner)) + (Bn * sin(inner)) + (AM * cos(lastTerm));
hold on
plot(xk, y1)
plot(px, interp)
total = A0 + Ahcoshx + Bhsinhx + (AM.*cos(n.*x)');

end

