#%%
import pandas as pd 
import numpy as np
p = 10 
N = 30
w = np.random.uniform(-1,1, (p,1))
X = np.random.normal(0,1, (N,p))
y = np.matmul(X,w) + np.random.normal(0,1,(N,1))
#%%

class layer:
    def __init__(self, out_dim, input=False, in_dim=None):
        self.out_dim = out_dim 
        if not input:
            self.weights = np.random.uniform(-1,1,(out_dim, in_dim)) 
            self.input_bit = 0
        else:
            self.input_bit = 1 
        
    def compute_self(self, z):
        if self.input_bit==0:
            self.z = np.matmul(self.weights,z) 
        else:
            self.z = z 
        return np.reshape(self.z, (-1,1))
    
class network:
    def __init__(self):
        self.layers = [] 
    
    def add_layer(self, layer):
        self.layers.append(layer)
        
    def compute_net_iter(self, x, L):
        if L==(len(self.layers)-1):
            q = self.layers[len(self.layers)-1].compute_self(self.layers[L-1].z)
            # print(q)
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
    
    def mse(self, y, yhat):
        return np.sum(np.power(y-yhat,2))/len(y)
    
layer0 = layer(10, input=True)  
layer1 = layer(10, in_dim=layer0.out_dim)  
layer2 = layer(1, in_dim=layer1.out_dim)
#%%
net = network()
net.add_layer(layer0)
net.add_layer(layer1)
net.add_layer(layer2)
yhat = net.compute_output(X)
net.mse(y, yhat)
# %%

# %%
