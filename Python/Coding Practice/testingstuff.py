import tensorflow as tf
import numpy as np
import pandas as pd


gdp = pd.read_csv("GDP.csv")
print(gdp)

tf.keras.Sequential([])

loggdp = np.log10(gdp["GDP"])

print(100*(loggdp[2:]- loggdp[1:(len(loggdp)-1)]))
