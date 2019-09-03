__author__ = 'dillonflannery-valadez'

import numpy as np
import matplotlib.pyplot as plt
import time



class ValueFunction:
    def __init__(self):
        self.N = 100
        self.state_space = np.linspace(0,1, self.N)
        self.value_function = {}
        self.p_func = {}
        for i in self.state_space:
            self.value_function[i] = 0
            self.p_func[i] = 0

        self.policy = np.zeros(self.N)
        self.A = 4.0
        self.beta = 0.90
        self.a = 1.0
        self.plotTitle = 'Value Function and Policy Function Plot'
        self.kstar = ((self.beta*self.A) - 1) / (self.a*(self.A - 1)*(((self.A**2)*self.beta)-1))

    def calculate_utils(self, k, k_prime, updated_vfunc, a = 1.0, A = 4.0, beta = 0.90):
        if A*k < k_prime:
            return beta*self.value_function[A*k]
        else:
            utils = ((A*k) - k_prime) - ((a/2.0) * (((A*k) - k_prime)**2.0) ) + (beta*updated_vfunc)
            return utils

    def search_for_max(self, k_fixed_index):
        """
        Iterates over the entire state space and returns the maximum value for
        the value function. First it fills a tmp vector, V_i,j and then takes the maximum
        of it.
        :param k_fixed_index: Your given state today
        :param updated_vfunc: Updated value function or guess.
        :return: Max of the choices of state tomorrow (control).
        """
        tmp = []
        end_state_space = self.N
        for k_prime_index in range(0, end_state_space):
            dict_state_key = self.state_space[k_prime_index]
            util_calculation = self.calculate_utils(self.state_space[k_fixed_index],
                                                     self.state_space[k_prime_index],
                                                    self.value_function[dict_state_key])
            tmp.append(util_calculation)
        self.value_function[self.state_space[k_fixed_index]] = max(tmp)
        self.p_func[self.state_space[k_fixed_index]] = self.state_space[tmp.index(max(tmp))]

    def breakpoint(self, state):
        n = 0
        while (self.A**n)*state < self.kstar:
            n+=1
            if (self.A**n)*state > self.kstar:
                return n
        else:
            return -100000

    def update_value_and_policy_function(self):
        """
        Corresponds to matrix V_1= {V_1^1}_i=1 ^n_k. The maximum value given choice of state tomorrow.
        :param updated_vfunc: updated value function
        """
        for state_index in range(0, self.N):
            state = self.state_space[state_index]
            if state < self.kstar:
                if state_index == 0:
                    self.p_func[state] = self.A * state
                    self.search_for_max(state_index)
                else:
                    self.p_func[state] = self.A * state
                    self.search_for_max(state_index)
            else:
                self.search_for_max(state_index)

    def contraction_mapping(self, iterations):
        maxIterations = 0
        while maxIterations < iterations:
            self.update_value_and_policy_function()
            maxIterations += 1

    def get_yvalues(self, iters):
        y_val = []
        y_pol = []
        self.contraction_mapping(iters)
        for i in self.state_space:
            y_val.append(self.value_function[i])
            y_pol.append(self.p_func[i])
        return y_val, y_pol

def theoretical_value(a=1.0, A=4.0, beta=.90):
    chi = (1 - (beta*A))/ (a*A*beta*(A-1))
    # psi_0 = .5 * (1/(1-beta))*chi * (A*(1-(A*beta)))/(A-1)
    psi_0 = .5 * 1/(a*beta*(1-beta))* ((1- (A*beta))/ (A-1))**2
    psi_1 = ((((A**2)*beta) - 1.0)/ beta) * ( 1/ (A-1))
    psi_2 = (-.50* (((A**2)*beta) - 1)*a)/beta

    cutoffpoint = ((beta*A)-1.0)/(a*(A-1)*(((A**2)*beta) - 1))
    kstate = np.linspace(0, 1, 1000)
    val = np.zeros(len(kstate))
    pol = np.zeros(len(kstate))
    for i in range(0,len(kstate)):
        if kstate[i] < cutoffpoint:
            n = 0
            pol[i] = A*kstate[i]
            while (A**n) * kstate[i] < cutoffpoint and i != 0:
                n+=1
                if (A**n) * kstate[i] >= cutoffpoint:
                    val[i] = (beta**n)*(psi_0 + psi_1*kstate[i]*(A**n) + psi_2*(kstate[i]*(A**n))**2)
                    break
        else:
            pol[i] = (1/(A*beta))*kstate[i] + ((beta*A) -1)/(a*A*beta *(A-1))
            val[i] = (psi_0 + psi_1*kstate[i] + psi_2*(kstate[i]**2))
    return val,pol

b = time.time()
theo = theoretical_value()

v= ValueFunction()
iters = [10,20,40]

for i in iters:
    valf_pol = v.get_yvalues(i)
    if i == 40:
        plt.plot(v.state_space, theo[0])
        plt.plot(v.state_space, theo[1])
        plt.plot(v.state_space, valf_pol[0])
        plt.plot(v.state_space,valf_pol[1])

    else:
        plt.plot(v.state_space, valf_pol[0])

plt.title('Value Function After 10, 20 and 40 Iterations \n An Policy Function After 40 Iterations')
plt.ylabel('Value')
str = 'Grid Space Set to ' + str(v.N)
plt.xlabel(str)
e = time.time()
print "Run time for python value function (10, 20, 40 iterations, 1000 grid): %.3f" %(e-b)
plt.show()











