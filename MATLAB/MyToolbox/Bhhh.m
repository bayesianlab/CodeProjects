function [xk, B] = Bhhh(xk, LLFunction, y,X,varargin)
alphakk = 10;
alphak = 1;
alphamax = 100;
c1=1e-4;
K = length(xk);
steptol = 1e-10;
variableargs = nargin - 4;
if variableargs == 1
    foo = varargin{1};
    maxiter = 30;
    dispon = 0;
elseif variableargs == 2
    foo = varargin{1};
    maxiter = varargin{2};
    dispon = 0;
elseif  variableargs == 3
    foo = varargin{1};
    maxiter = varargin{2};
    dispon = varargin{3};
end

phialphakk = LLFunction(xk,y,X);
phialphak = phialphakk-1;

[gradkk, B] = CentralBhhh(xk, LLFunction, y,X);
pkk = -B\gradkk;
% dphikk = 0;
% dphik = 0;
% d1 = 0;
% d2 = 1;
opts = optimoptions(@fmincon, 'Display', 'off', 'FiniteDifferenceType', 'central');

if dispon == 1
    t = 0;
    fprintf('Iteration Optimality  Function Value \n')
    while t < maxiter
        if t > 1
            fcon = @(ak) LLFunction(xk+ak*pkk,y,X);
            alphak = fmincon(fcon, alphak, [],[],[],[], 0,Inf,[], opts);
        end
        xkk = xk + alphak.*pkk;
        if abs(max(xkk - xk)) < 1e-6
            break
        end
        [gradkk, B] = CentralBhhh(xk, LLFunction, y,X);
        pkk = -B\gradkk;
        fvalk = LLFunction(xk, y, X);

        xk = xkk;
        
        %         if phialphakk > phialphak
        %             alphaj = alphakk - (alphakk- alphak)* (dphikk + d2 - d1)/ (dphikk - dphik + 2*d2);
        %             conda = LLFunction(alphaj*pkk + xk,y, X);
        %             condb = LLFunction(alphak*pkk + xk,y, X);
        %             condc = LLFunction(xk,y, X);
        %
        %             if conda > condc | conda > condb
        %                 alphamax = alphaj;
        %             else
        %                 [gradj, ~] = CentralBhhh(xk + alphaj.*pk, LLFunction, y,X);
        %                 condd = gradj'*pkk;
        %
        %                 if abs(condd) < -c2
        %
        %                 end
        %
        %             end
        %         end
        %
        %         if norm(xkk - xk) < steptol
        %             break
        %         end
        %         fvalx0 = LLFunction(xk, y, X);
        %         fval = LLFunction(xkk, y, X);
        %         [gradkk, B] = CentralBhhh(xkk, LLFunction, y,X);
        %         [gradkk, B] = CentralBhhh(xkk, LLFunction, y,X);
        %
        %         xk = xkk;
        %         pkk = -B\gradkk;
        %
        %
        %
        %
        %         alphakk = alphakkk;
        %
        infnorm = max(abs(gradkk));
        if infnorm < foo
            break
        end
        fprintf('%i\t%.2e\t%2g \n', t, infnorm,  fvalk)
        t= t+1;
    end
    
    
else
    t = 0;
    while t < maxiter
        if t > 1
            fcon = @(ak) LLFunction(xk+ak*pkk,y,X);
            alphak = fmincon(fcon, alphak, [],[],[],[], 0,Inf,[], opts);
        end
        xkk = xk + alphak.*pkk;
        if abs(max(xkk - xk)) < 1e-6
            break
        end
        [gradkk, B] = CentralBhhh(xk, LLFunction, y,X);
        pkk = -B\gradkk;

        xk = xkk;
end
end

