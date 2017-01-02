clear 
clc
a = 1;
A = 4;
beta = 0.9;

k_lower = 0;
k_bar = 1/a;

N = 100;
X = linspace(k_lower,k_bar,N);

% dont need that big of a value funciton :), this is your "guess"
V = zeros(N, 1);
policy = zeros(N,1);
Iterations = 10;
for m = 1:Iterations
    % F can be as big as you had it, but it doesnt need to be.
    % it is the temporary matrix searching for a max. It is re made
    % every iteration. It can be zeros too. 
    F = zeros(N,1);
    for i = 1:N
         k = X(i);   %k is current capital
    for j = 1:N;
            k_next = X(j);    %k_next is next period's capital
            
            % Wait! this was backwards!! I switched so now it 
            % works. If Ak is less than kprime its negative.
            if (A*k) < k_next  
                % This above condition means consumption negative,
                % thats bad, make sure its never a max. 
                F(j,1) = -99999*999999;
            else
                % youll want an else to get when the above
                % condition doesnt hold. 
                utility = (A*k - k_next) - (a/2)*((A*k - k_next)^2);
                % makes sure you get the value of the jth period
                F(j,1) = utility + beta*V(j,1);    
            end
            % Now that the inner loop is done, you have performed
            % an iteration of the Bellman, put the max in the ith
            % place of the V
            
    end
    [V(i,1), indx] = max(F);
    policy(i,1) = X(indx);
    end
end
plot(X, V)
plot(X, policy)