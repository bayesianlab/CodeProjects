from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer
from sklearn.impute import KNNImputer
import numpy as np 
import pandas as pd 
from time import time 


def check_if_all_nan(prediction_data):
    nan_rows = prediction_data.isna().sum() 
    if (nan_rows == prediction_data.shape[0]):
        return True
    return False 

def multivariateImputation(prediction_data):
    """
    Uses a regression analysis to impute values into the columns that are nans. 
    Dealing with nans in categorical columns should be done first so that 
    values are not imputed into categorical columns which are floats, but 
    categorical columns could be import predictors for the imputed values and 
    should be included.

    Input: 
        A dataset with missing values needing to be imputed. (Usually the RHS variables)
    
    Returns:
        A dataset with the missing values imputed.  
    """
    check_if_all_nan(prediction_data)
    imp = IterativeImputer(max_iter=10)
    imp.fit(prediction_data)
    names = prediction_data.columns
    prediction_data = imp.transform(prediction_data)
    return pd.DataFrame(prediction_data, columns=names)

def knn_imputation(prediction_data):
    """
    Uses a k-nearest neighbors to impute values into the columns that are nans. 
    Dealing with nans in categorical columns should be done first so that 
    values are not imputed into categorical columns which are floats, but 
    categorical columns could be import predictors for the imputed values and 
    should be included. 

    Input: 
        A dataset with missing values needing to be imputed. (Usually the RHS variables)
    
    Returns:
        A dataset with the missing values imputed. 
    """
    check_if_all_nan(prediction_data)
    names = prediction_data.columns
    imp = KNNImputer(n_neighbors=5, weights='uniform', metric='nan_euclidean',
                     copy=True, add_indicator=False)
    imp.fit(prediction_data)
    prediction_data = imp.transform(prediction_data)
    return pd.DataFrame(prediction_data, columns=names)

def univariate_imputation(prediction_data):
    """
    Uses a univariate imputation to impute values into the columns that are nans. 
    Dealing with nans in categorical columns should be done first so that 
    values are not imputed into categorical columns which are floats, but 
    categorical columns could be import predictors for the imputed values and 
    should be included. 

    Input: 
        A dataset with missing values needing to be imputed. (Usually the RHS variables)
    
    Returns:
        A dataset with the missing values imputed. 
    """
    # check_if_all_nan(prediction_data)
    imp = KNNImputer(n_neighbors=5, weights='uniform')
    imp.fit(prediction_data)
    names = prediction_data.columns
    prediction_data = imp.transform(prediction_data)
    return pd.DataFrame(prediction_data, columns=names)

def timer(func):
    def wrapped(*args, **kwargs):
        t1 = time()
        result = func(*args, **kwargs)
        t2=time()
        print('function time: {:.4f}'.format(t2-t1))
        return result
    return wrapped 


if __name__ == "__main__":
    # Example usage 
    print("Imputation Examples")
    print("Multivariate")
    Frame = pd.DataFrame({"ContinuousCol1":[0.1, 100, 35, 65, np.nan], "ContinuousCol2":[np.nan, 35, np.nan, 7, .01], "CatCol1":["Cat", "Cat", "Dog","Dog", "Cat"]})
    print(Frame)
    Frame = pd.get_dummies(Frame, columns=['CatCol1'])
    print(multivariateImputation(Frame))

    print("KNN Example")
    Frame = pd.DataFrame({"ContinuousCol1":[0.1, 100, 35, 65, np.nan], "ContinuousCol2":[np.nan, 35, np.nan, 7, .01], "CatCol1":["Cat", "Cat", "Dog","Dog", "Cat"]})
    print(Frame)
    Frame = pd.get_dummies(Frame, columns=['CatCol1'])
    print(knn_imputation(Frame))
    
    