
import numpy as np
import pandas as pd
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt

def pcExtract(data,col):
    u,s,vh = np.linalg.svd(data)
    pca = np.matmul(u,np.diag(s))
    return pca[:,col]

world_data = pd.read_csv('kow_standardized.csv')
world_data = world_data.transpose()

world_factor = pcExtract(world_data,1)

north_america = [0,8]
oceania = [9,14]
latin_america = [15,68]
europe = [69,122]
africa = [123, 143]
asia_minor = [144,161]
asia_dev = [162, 179]





