clear;
clc;
format;
data_imp;

X = [const x_1 x_2];
beta = [.01,.01,.01]';
% Tolerance for error on optimzation, step size for steepest descent.
tols = [1e-5, 1e-6, 1e-7];
step = 1e-5;

% %% Probit Estimation
% for t = 1:length(tols)
%     currentIter = sprintf('\nCurrent tolerance level %d\n', tols(t));
%     disp(currentIter)
%     tic
%     [mles, v] = probit_steepestDescentMethod(beta, X, y, step,tols(t))
%     toc 
% 
%     tic
%     [mlesN, vs ]=  probit_Newton_Method(beta, X,y, tols(t))
%     toc
% 
%     tic
%     disp('PROBIT F MIN UNC')
%     [est_prob, fval, output, exitflag, grad, hessian_Probit] = probitMinUnc([.01,.01,.01]', y,X)
%     toc
%     fish_prob = inv(hessian_Probit);
%     variances_prob = sqrt(diag(fish_prob))
%     %% Logit Estimation
%     disp('LOGIT ESTIMATION')
%     tic
%     [e_logN, v_logN] = logit_NR_Method(beta, X,y, tols(t))
%     toc
% 
%     tic
%     [e_logS, v_logS] = logit_Steepest_Descent(beta, X, y, step, tols(t))
%     toc
%     
%     tic
%     disp('LOGIT F MIN UNC')
%     [estimates_logit, fval, output, exitflag, grad, hessian_LOGIT ] = logitMinUnc(beta, X,y)
%     toc
%     fish = inv(hessian_LOGIT);
%     variances = sqrt(diag(fish))
%     disp('END LOGIT ESITMATION')
% 
% end

%     %% Non-Linear Least Squares Estimation
    tic
    disp('NON LINEAR LEAST SQUARES')
    [estimates, fval, output, exitflag, grad, hessian_NLLS, SE_Betas ] =...
        nlls_minunc(beta, X,y)
    toc
%     disp('END ITERATION')