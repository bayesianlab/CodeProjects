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
    def __init__(self, out_dim, input=False, in_dim=None):
        self.out_dim = out_dim 
        if not input:
            self.weights = np.random.normal(0,1.0/out_dim,(out_dim, in_dim)) 
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
    
    def grad_E(self, yhat, y):
        return np.reshape(np.sum(yhat - y), (-1, 1))
    
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


    def update(self, X,y, epochs=10, batch_size=32, lr=.01):
        deltas = {} 
        for i in range(1,len(self.layers)):
            deltas[i] = 0  
        
        for e in range(epochs):
            Xbatches, ybatches = self.batch_data(X,y, batch_size)
            batches = len(ybatches)
            for b in range(batches):
                yhat = self.compute_output(Xbatches[b])
                grad_E = self.grad_E(yhat, ybatches[b])/len(yhat)
                z = np.reshape(self.layers[-2].z, (-1,1))
                grad_W = np.matmul(grad_E, z.T)
                deltas[len(self.layers)-1] = grad_W
                for L in reversed(range(1, len(self.layers)-1)):
                    grad_E = np.matmul(self.layers[L+1].weights.T, grad_E)
                    z = np.reshape(self.layers[L-1].z, (-1,1))
                    grad_W = np.matmul(grad_E, z.T)
                    deltas[L] = grad_W
                for L in range(1,len(self.layers)):
                    self.layers[L].weights = self.layers[L].weights - (lr*deltas[L]) 
            yhat = self.compute_output(X)
            err = self.mse(yhat, y)
            print(err)
    
layer0 = layer(X.shape[1], input=True)  
layer1 = layer(10, in_dim=layer0.out_dim)  
layer2 = layer(1, in_dim=layer1.out_dim)

net = network()
net.add_layer(layer0)
net.add_layer(layer1)
net.add_layer(layer2)

net.update(X,y, epochs=30, batch_size=30, lr=.01)
yhat = net.compute_output(X)
plt.plot(yhat)
plt.plot(y)
plt.show()

# %%
