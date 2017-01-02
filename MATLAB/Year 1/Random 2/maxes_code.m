%% Dynamic Programming Homework 
% Question #2  "Numerical Solution of the Optimal Growth Problem"
% Max Littlejohn



%% Create the Value Function
% First, define parameters

%Create the policy and value fuction and consumption C
%C = Ak + k_next
%V = Ct - (a/2)*C^2 + beta*V_next
%k_next = (1/A*beta)*k + beta*(A-1)/(a*A*beta*(A-1)
%V = [a*(1-beta*A.^2)/(2*beta)]*k.^2 - [(1-beta*A.^2)/(Beta*(A-1))]*k
%+ [(1-beta*A.^2)/(2*beta*a*((A-1).^2)*(1-beta))]

%Set lower and upper limits for capital control k

%Need to discretize the state space from which we can draw
%values of k from
%Use 800 intervals of capital that we can draw from

%Create the state space

%Transpose X into a 800x1 column
X = X';

%Set number of value function iterations equal to 40 and create a matrix
%for the consumption function with non-numerical entries
Iterations = 40;
F = NaN(Iterations,N,N);

%%
%Create a zero matrix of size 41x800 to store our values for the value 
%function V. 
V = zeros(Iterations+1, N, 1); 
%Create a zero matrix of size 40x800 to store our values for the maximized
%value function from the previous iteration
V_previous = zeros(Iterations, N, 1);

%Create a loop that will determine the value of consumption in each period
%using the F function.
%If consumption is less than zero, set it equal to negative infinity since
%negative consumption is not feasible.
for m = 1:Iterations
    for i = 1:N
        k = X(i);   %k is current capital
    for j = 1:N;
            k_next = X(j);    %k_next is next period's capital
            F(m,i,j) = -inf;    %if k_next isn't feasible, return -inf
            
            if k_next <= (A*k)
                F(m,i,j) = (A*k - k_next) - (a/2)*((A*k - k_next).^2);
                
            end
    end
    end
end

%Create a loop that will loop over every possible value of k_next for every
%possible value of k. This is a loop inside a loop.
%Then we must find the maximum value for the value function for each value
%of k.  Therefore, we find the pair of k and k_next that maximize the value
%function for all 800 possible values of k.
%We must find a maximum V for K and then use that V in the next iteration
%for the all possible values of k.  The maximum V is denoted as V_previous 
%and is 0 for the first iteration.
for m = 1:Iterations
    for i = 1:N  %all values of k
        for j = 1:N  %all values of k_next
            V(m+1,i,j) = F(m,i,j) + beta*V_previous(m,i);
        end
    end
    for k = 1:N
        V_previous(m+1,k) = max(V(m+1,k,:));
    end
end

%Now we need to store all the values of k_next that maximize the value
%function for every value of k.
k_next_max = zeros(Iterations,N);

%Create a loop that will loop through every value of V we found for every
%possible pair of k and k_next and compare it to the max V we found for the 
%corresponding k.
%If V is equal to the max V, store the value of k_next.
%Do this for all 40 iterations.
for m = 1:Iterations
    for i = 1:N   %all values of k
    for j = 1:N  %all values of k_next
            if V(m+1,i,j) == V_previous(m+1,i) %find k_next that maximizes
                                               %V for k(i)
                k_next_max(m+1,i) = X(j);
            end
    end
    end
end


        
 %%
 %Now that we have found the numerical solutions to the value function and 
 %the policy function for 40 iterations, we need to compare it to the
 %analytical solution we found in Question 1.
 
 %We need to find a numerical value for the analytical value function for
 %each possible value of k.  That is, 800 values.
 %Create a zero vector to store each value of the analytical value function
 V_analytical = zeros(N,1);
 
 %Create a loop that will solve the analytical value function for each 
 %possible value of k and store that value in the V_analytical vector.
 for m = 1:N
     V_analytical(m,1) = ((1-(beta*(A.^2)))*a*(X(m,1).^2))/(2*beta) + (((beta*(A.^2))-1)*X(m,1))/(beta*(A-1)) + (((beta*A)-1).^2)/(2*a*beta*(1-beta)*((A-1).^2));
 end
 
 %% Plotting
 %Need to plot the numerical value function after 10, 20, and 40 iterations
 %transpose V_previous
 V_previous = V_previous';
 %obtain values for the 10th, 20th, and 40th iteration for every value of k
 V_previous_10 = V_previous(:,10);
 V_previous_20 = V_previous(:,20);
 V_previous_40 = V_previous(:,40);
 
 %Plot the value function against k for 10, 20, and 40 iterations in one 
 %plot.
 figure
 subplot(1,2,1)
 plot(X,V_previous_10,'-g')
 hold on
 plot(X,V_previous_20,'-r')
 hold on
 plot(X,V_previous_40,'-b')
 legend('10 Iterations','20 Iterations','40 Iterations')
 title('Value Function for 10, 20, and 40 Iterations')
 xlabel('Capital Stock: k')
 ylabel('Value Function: V')
 axis([0 1 -5 5.5])
 
 %Plot the analytical value function against k
 subplot(1,2,2)
 plot(X,V_analytical)
 title('Analytical Value Function')
 xlabel('Capital Stock: k')
 ylabel('Value Function: V')
 axis([0 1 0 5.5])
 
 %Need to plot the policy function after 40 iterations
 %obtain the value k_next_max for every k from the final iteration
 k_policy_40 = k_next_max(41,:);
 k_policy_40 = k_policy_40';
 Policy_40 = k_policy_40(:,1);
 
 %Plot the policy function after the 40th iteration. 
 %This means we are plotting the k_next values that maximize the value
 %fuction at every value of k against k.
 %We also need to plot the 45 degree line on the same plot
 figure
 subplot(1,1,1)
 plot(X,Policy_40,'-b')
 hold on
 plot(X,X,'--r')   %the 45 degree line
 title('Policy Function for 40 Iterations')
 legend('Policy Function','k = k(next period)')
 xlabel('Capital Stock: k')
 ylabel('Policy Function: k(next period)')
 axis([0 1 -0.2 1.5])
 




