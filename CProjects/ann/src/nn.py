#%%
import pandas as pd
import numpy as np 
import tensorflow as tf
import keras 
import matplotlib.pyplot as plt 
# %%
p = 10
N = 30 
np.random.seed(116)
w = np.random.uniform(-1,1,size=(p,1))
X = np.random.normal(0,1, size=(N, p))
y = np.matmul(X,w) + np.random.normal(0,1,size=(N,1))
#%%
tf.keras.utils.set_random_seed(102)
I = keras.layers.Input(shape=(X.shape[1],))
L = keras.layers.Dense(units=10, use_bias=False)(I)
out = keras.layers.Dense(units=1, use_bias=False)(L)
model = keras.Model(I, out)
model.summary()
model.compile(loss=keras.losses.MeanSquaredError(), optimizer=keras.optimizers.SGD(learning_rate=.01))
model.fit(X, y, batch_size = 1, epochs=40, shuffle=False )
yhat = model.predict(X)
plt.plot(y)
plt.plot(yhat)

# %%
