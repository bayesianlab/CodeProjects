__author__ = 'dillonflannery-valadez'
import numpy as np
import scipy.spatial
import matplotlib.pyplot as plt

def theoretical_value(a=1.0, A=4.0, beta=.90):
    chi = (1 - beta*A)/ (a*A*beta*(A-1))
    psi_0 = .5 * (1/(1-beta))*chi * (A*(1-A*beta))/(A-1)
    psi_2 = (((-0.50 * (A**2) * beta) - 1.0)*a)/beta
    psi_1 = (((A**2)*beta) - 1)/((beta *A)-1)
    cutoffpoint = ((beta*A)-1.0)/(a*(A-1)*(((A**2)*beta) - 1))
    kstate = np.linspace(0, 1, 50)
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
                    # print (A**n) * kstate[i], cutoffpoint,  (A**(n-1))*kstate[i]
                    break
        else:
            pol[i] = (1/(A*beta))*kstate[i] + ((beta*A) -1)/(a*A*beta *(A-1))
            val[i] = (psi_0 + psi_1*kstate[i] + psi_2*kstate[i]**2)
    # print kstate
    # print val
    plt.plot(kstate, val)
    plt.plot(kstate, pol)
    plt.show()
theoretical_value()

class ValueFunctionIteration():

    def __init__(self):

        self.N = 20
        self.state_space = np.linspace(0,1, self.N)
        self.value_function = np.zeros(self.N)
        self.canidate = np.zeros(self.N)
        self.policy = np.zeros(self.N)
        self.A = 4.0
        self.beta = 0.90
        self.a = 1.0
        self.plotTitle = 'Value Function and Policy Function Plot'
        self.kstar = ((self.beta*self.A) - 1) / (self.a*(self.A - 1)*(((self.A**2)*self.beta)-1))
        self.value_dictionary = {}
        self.cm = [ 'r', 'c', 'm','m','y','k']



    def calculate_utils(self, k, k_prime, updated_vfunc, a = 1.0, A = 4.0, beta = 0.90):
        utils = ((A*k) - k_prime) - ((a/2.0) * (((A*k) - k_prime)**2.0) ) + (beta*updated_vfunc)
        return utils

    def search_for_max(self, k_fixed_index, updated_vfunc):
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

            util_calculation = self.calculate_utils(self.state_space[k_fixed_index],
                                                     self.state_space[k_prime_index],
                                                    updated_vfunc[k_prime_index])

            tmp.append(util_calculation)

        return max(tmp), tmp.index(max(tmp))

    def update_value_function(self, updated_vfunc):
        """
        Corresponds to matrix V_1= {V_1^1}_i=1 ^n_k. The maximum value given choice of state tomorrow.
        :param updated_vfunc: updated value function
        """
        for state_index in range(0, self.N):
            max_value = self.search_for_max(state_index, updated_vfunc)
            self.value_function[state_index] = max_value[0]
            self.value_dictionary[self.state_space[state_index]] = max_value[0]
            if self.state_space[state_index] < self.kstar:
                self.policy[state_index] = self.A*self.state_space[state_index]

            else:
                self.policy[state_index] = self.state_space[max_value[1]]
        # for state_index in range(0,self.N):
        #     if state_index == 0:
        #         self.value_function[state_index] = 0
        #         continue
        #     if self.state_space[state_index] < self.kstar:
        #         n = self.breakpoint(self.state_space[state_index])
        #         a_pow = int(self.A** n)
        #         self.value_function[state_index] = (self.beta**(n)) * \
        #                                            self.value_dictionary.get(self.state_space[state_index]*a_pow)

    def breakpoint(self, state):
        n = 0
        while (self.A**n)*state < self.kstar:
            n+=1
            if (self.A**n)*state > self.kstar:
                return n
        else:
            return -100000

    def contraction_mapping(self, iterations):
        maxIterations = 0
        while maxIterations < iterations:
            self.update_value_function(self.value_function)
            maxIterations += 1

        return self.value_function

    def plot_contraction_mapping(self):
        iters = [10,20,40]
        for i in iters:
            self.contraction_mapping(i)
            # plt.figure(i)
            plt.plot(self.state_space, self.contraction_mapping(i),rand.choice(self.cm))
            plt.plot(self.state_space, self.policy)
            plt.title(self.plotTitle + ' with ' + str(i) + ' iterations')
        plt.show()

class ValueFunction:
    def __init__(self):
        self.N = 50
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
                    self.value_function[state] = 0
                else:
                    self.p_func[state] = self.A * state
                    exponent= self.breakpoint(state)
                    A_pow = int(self.A**exponent)
                    periods_of_no_consumption = A_pow* state
                    self.value_function[state] = (self.beta**exponent)* self.value_function[periods_of_no_consumption]
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
    chi = (1 - beta*A)/ (a*A*beta*(A-1))
    psi_0 = .5 * (1/(1-beta))*chi * (A*(1-A*beta))/(A-1)
    psi_2 = (((-0.50 * (A**2) * beta) - 1.0)*a)/beta
    psi_1 = (((A**2)*beta) - 1)/((beta *A)-1)
    cutoffpoint = ((beta*A)-1.0)/(a*(A-1)*(((A**2)*beta) - 1))
    kstate = np.linspace(0, 1, 50)
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
                    # print (A**n) * kstate[i], cutoffpoint,  (A**(n-1))*kstate[i]
                    break
        else:
            pol[i] = (1/(A*beta))*kstate[i] + ((beta*A) -1)/(a*A*beta *(A-1))
            val[i] = (psi_0 + psi_1*kstate[i] + psi_2*kstate[i]**2)
    return val,pol