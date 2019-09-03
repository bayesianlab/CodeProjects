__author__ = 'dillonflannery-valadez'
import pandas
import numpy as np
import math


loc1 = r'/Users/dillonflannery-valadez/Google Drive/MATLAB/Macro Swanson/output.csv'
loc2= r'/Users/dillonflannery-valadez/Google Drive/MATLAB/Macro Swanson/cpi.csv'
loc3= r'/Users/dillonflannery-valadez/Google Drive/MATLAB/Macro Swanson/t_bonds.csv'
out = pandas.read_csv(loc1)
cpi =  pandas.read_csv(loc2)
tbonds = pandas.read_csv(loc3)

def createTableLaTeX(textFile):
    str = ''
    f = open(textFile, 'r')

    for line in f:
        lst = line.split()

        str += addAnds(lst) + '\n'
    str =addEnviorment(str)
    print str
    return str

#
# f = open('trial.txt', 'r')
# for line in f:
#     line.split()

def addAnds(line):
    str= ''
    c = 0
    lng = len(line)
    for item in line:
        c += 1
        if c == lng:
            str += item + r' \\'
            break
        else:
            str += item + ' & '
    return str

def addEnviorment(str):
    bgnTable = '\\begin{tabular}\n'
    endTable = '\n\end{tabular}'
    str = bgnTable + str + endTable
    return str

# createTableLaTeX('cov_mat_v12_q2.txt')
# createTableLaTeX('v12_fore_ldout.txt')
# createTableLaTeX('var12_forecasts.txt')
# createTableLaTeX('var2_forecasts.txt')

createTableLaTeX('steepest_descent_probit.txt')
createTableLaTeX('probit_newton.txt')
createTableLaTeX('estimates_pl.txt')