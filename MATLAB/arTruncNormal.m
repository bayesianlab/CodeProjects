function [x, sup] = arTruncNormal(alpha, beta, mu, sigmaSqd, N)

constantFunc = @(x, alpha,beta,mu,sigmaSqd) ...
    ( (gamma(alpha)) / (sqrt(2*pi*sigmaSqd)*beta^alpha) ) * ...
    x^(1-alpha) * ...
    exp( (x*beta) - (( (x-mu)^2 ) / (2*sigmaSqd)) );

deriv_f_div_g = @(x, alpha, beta, mu, sigmaSqd) ((1 - alpha)./ x) +...
    (beta - ((x-mu)/(sigmaSqd)));


paramDeriv = @(x) deriv_f_div_g(x,alpha, beta,mu, sigmaSqd);
minVal = fzero(paramDeriv, 2);
sup = constantFunc(minVal, alpha, beta, mu, sigmaSqd);
logfDcg = @(x) log_f_gTsup(x,alpha,beta,mu,sigmaSqd,sup);

x = zeros(N,1);
accepts = 1;

while(accepts <= N)
    u = unifrnd(0,1,1,1);
    prop = gamrnd(alpha, 1/beta, 1,1);
    if( log(u) <= logfDcg(prop) ) 
        x(accepts,1) = prop;
        accepts = accepts + 1;
    end
end
end

