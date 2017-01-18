function [ X_Next] = newtonStep( sys, jacob, X_0, alpha)
H = -linsolve(jacob(X_0, alpha), sys(X_0, alpha));
X_Next = X_0 + H;
end

