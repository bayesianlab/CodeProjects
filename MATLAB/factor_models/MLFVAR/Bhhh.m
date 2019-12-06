function [] = Bhhh(guess, LLFunction, y,X,h, Ftol)
N=length(guess);
keepgrad=100.*ones(N,1);
initpoint=guess;
for t = 1:1000
    increasing = 1;
    lambda = 1;
    [grad, B] = CentralBhhh(guess, LLFunction, y,X,h);
    newguess = (lambda.*B)\grad;
    newguess=newguess+guess;
    guess=newguess;
%     Fval = LLFunction(newguess,y,X);
%     if LLFunction(guess,y,X)  < Fval
%         fprintf('notless\n')
%         while increasing == 1
%             newguess = (lambda.*B)\grad;
%             newguess=newguess+guess;
%             lambda = lambda.*.5;
%             Fval = LLFunction(newguess,y,X);
%             if Fval <  LLFunction(guess,y,X)
%                 fprintf('better guess\n')
%                 increasing=0;
%                 guess=newguess;
%             end
%         end
%     else
%         guess=newguess;
%     end    
end
newguess
end

