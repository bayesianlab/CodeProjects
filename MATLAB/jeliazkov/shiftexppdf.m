function [ y ] = shiftexppdf( mu, shift, x)
y = mu.*exp(-mu.*(x - shift));
end

