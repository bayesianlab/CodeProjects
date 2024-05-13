#%%
import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt 
p = 10
N = 30
w = np.random.uniform(-1,1, (p,1))
X = np.random.normal(0,1, (N,p))
y = np.matmul(X,w) + np.random.normal(0,1,(N,1))
#%%

class layer:
    def __init__(self, out_dim, input=False, output=False, in_dim=None):
        self.out_dim = out_dim 
        self.input_bit=False
        self.output_bit=False  
        if not input and not output:
            self.weights = np.random.normal(0, .5,(out_dim, in_dim)) 
            self.input_bit = 0
        elif output:
            self.weights = np.random.normal(0, .5,(out_dim, in_dim)) 
            self.output_bit = 1
        else:
            self.weights = None 
            self.input_bit = 1 
        
    def compute_self(self, z):
        if self.input_bit==0:
            self.z = np.matmul(self.weights,z) 
        else:
            self.z = z 
        return np.reshape(self.z, (-1,1))
    
    def grad_E_w(self, z_input, yhat=None, y=None, output_delta=None, Output_Weights=None):
        if (self.output_bit==True) and (y is not None) and (yhat is not None):
            self.delta_E = self.grad_E_z(yhat, y)
            del_W = self.delta_E * z_input.T 
            del_Wl1 = np.abs(del_W) 
            del_W[del_Wl1<1e-7] = 0 
            return del_W
        elif (not self.input_bit) and (output_delta is not None) and (Output_Weights is not None):
            self.delta_E = Output_Weights.T*output_delta 
            del_W = self.delta_E * z_input.T 
            del_Wl1 = np.abs(del_W) 
            del_W[del_Wl1<1e-7] = 0 
            return del_W
        else:
            raise Exception('Invalid input in grad_E_w. Called gradient on input layer?')

    def grad_E_z(self, yhat, y):
        return np.reshape(np.sum(yhat - y), (-1, 1))
    
class network:
    def __init__(self):

        self.layers = [] 
    
    def add_layer(self, layer):
        self.layers.append(layer)
        
    def compute_net_iter(self, x, L):
        if L==(len(self.layers)-1):
            return np.squeeze(self.layers[len(self.layers)-1].compute_self(self.layers[L-1].z))
        if L==0:
            self.layers[0].compute_self(x)
            return self.compute_net_iter(self.layers[0].z, L+1)
        else:
            self.layers[L].compute_self(self.layers[L-1].z)
            return self.compute_net_iter(self.layers[L].z, L+1)
        
    def compute_output(self,X):
        y = [] 
        for i in range(X.shape[0]):
            y.append(self.compute_net_iter(X[i,:], 0))
        return np.reshape(np.array(y), (-1,1))
    
    def mse(self, yhat, y):
        return np.mean(np.power(yhat - y,2))
    
    def batch_data(self, X,y, size):
        nrows = X.shape[0]
        rand_rows = np.random.permutation(range(nrows))
        batches = int(nrows/size)
        rem = nrows%size 
        if rem:
            batches += 1
        b = 0 
        Xbatches = {}
        ybatches = {} 
        c = 0 
        while b < nrows:
            if b+size>nrows:
                e = nrows-b 
            else:
                e = size 
            r = rand_rows[b:(b+e)]
            Xbatches[c] = X[r,:]

            ybatches[c] = y[r,:]
            b+=size  
            c+=1
        return Xbatches, ybatches 
    
    def weight_gradient(self, X,y):
        epsilon = 1e-8
        grad = [] 
        for L in reversed(range(1, len(self.layers))):
            g = [] 
            for i in range(self.layers[L].weights.shape[0]):
                for j in range(self.layers[L].weights.shape[1]):
                    self.layers[L].weights[i, j] += epsilon 
                    yup = self.compute_output(X).sum().squeeze()
                    self.layers[L].weights[i, j] -= epsilon 
                    ydown = self.compute_output(X).sum().squeeze() 
                    g.append((yup - ydown)/(2*epsilon))
            grad.append(np.array(g))
        return grad 
    
    def check_gradient(self, X, y):
        yhat = self.compute_output(X) 
        old_cost = self.mse(yhat, y)
        print("current old_cost {}".format(old_cost))
        
        del_dict = {}
        for i in reversed(range(1, len(self.layers))):
            z_input = np.reshape(self.layers[i-1].z, (-1,1))
            if self.layers[i].output_bit==True:
                gw = self.layers[i].grad_E_w(z_input, yhat, y)
            else:
                deltas = self.layers[i+1].delta_E
                W = self.layers[i+1].weights
                gw = self.layers[i].grad_E_w(z_input, output_delta=deltas, Output_Weights=W)
            del_dict[i] = [] 
            del_dict[i].append(gw)

        delta = -1e-4
        for i in reversed(range(1, len(self.layers))):
            d = del_dict[i][0]
            for k in range(self.layers[i].weights.shape[0]):
                for j in range(self.layers[i].weights.shape[1]):
                    self.layers[i].weights[k,j] += delta
                    yhat = self.compute_output(X)
                    cost = self.mse(yhat, y)  
                    print('diff {}'.format(cost - (old_cost + d[k,j]*delta)))

    def update(self, X,y, epochs=10, batch_size=32, lr=.01):
        Xbatches, ybatches = self.batch_data(X,y, batch_size)
        batches = len(ybatches)
        for e in range(epochs+1):
            for b in range(batches):
                store_grads = {}
                M = len(ybatches[b]) 
                for L in reversed(range(1,len(self.layers))):
                    gradF = np.zeros(self.layers[L].weights.shape)
                    store_grads[L] = [] 
                    for k in range(ybatches[b].shape[0]):
                        xb = np.reshape(Xbatches[b][k,:], (1,-1))
                        yb = np.reshape(ybatches[b][k,:], (1,1))
                        yhat = self.compute_output(xb)
                        z_input = np.reshape(self.layers[L-1].z, (-1,1))
                        if self.layers[L].output_bit:
                            gradF += self.layers[L].grad_E_w(z_input, yhat, yb)
                        else:
                            deltas = self.layers[L+1].delta_E
                            W = self.layers[L+1].weights
                            gradF += self.layers[L].grad_E_w(z_input, output_delta=deltas, Output_Weights=W)
                    store_grads[L] = lr*gradF/M
                for L in range(1, len(self.layers)):
                    self.layers[L].weights -= store_grads[L]
            yhat = self.compute_output(X)
            print('error {}'.format(self.mse(yhat, y)))


            


                        


    
layer0 = layer(X.shape[1], input=True)  
layer1 = layer(10, in_dim=layer0.out_dim)  
layer2 = layer(1, in_dim=layer1.out_dim, output=True)

net = network()
net.add_layer(layer0)
net.add_layer(layer1)
net.add_layer(layer2)

# net.check_gradient(X,y)
net.update(X,y, epochs=50, batch_size=30, lr=.01)
yhat = net.compute_output(X)
plt.plot(yhat, label='yhat')
plt.plot(y,label='y')
plt.legend() 
plt.show()

# %%
