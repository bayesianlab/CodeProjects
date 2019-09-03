__author__ = 'dillonflannery-valadez'
import numpy
import pylab
import math
from matplotlib import gridspec
import scipy
from scipy import stats
from scipy.stats import t
import matlab.engine as mat
import csv
import econometrics_q2_cauchy
import econometrics_q2_t
import os

x = econometrics_q2_cauchy.CauchyStuff()
x.monteCarlo(5000)
x.createPlots("Cauchy Distribution")

y = econometrics_q2_cauchy.WeridNormal()
y.monteCarlo(5000)
y.createPlots("Normal (Var1 = 1, Var 2 = 400)")

z = econometrics_q2_t
zListofData = z.getTMeans(z.NSIMS)
z.createPlots(zListofData)
pylab.show()


def createDataFile(exportData, fileName):
    with open(fileName + ".csv", "w") as csvfile:
        converter = csv.writer(csvfile, delimiter=",")
        for row in exportData:
            converter.writerow(row)


createDataFile(x.allStats, 'cauchyData')
createDataFile(y.allStats, 'twoVarianceNormal')
createDataFile(z.totalData, 'tDistribution')