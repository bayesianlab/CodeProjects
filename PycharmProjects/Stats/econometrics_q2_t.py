__author__ = 'dillonflannery-valadez'

import numpy
import pylab
import math
from matplotlib import gridspec
import scipy
from scipy import stats
from scipy.stats import t
import csv




def tMean(array, trim):
    newArray = []
    upperPercentile = 100 - (trim/2.0)
    lowerPercentile = trim/2.0
    lBound =  numpy.percentile(array, lowerPercentile)
    uBound = numpy.percentile(array, upperPercentile)
    for data in array:
        if data > lBound and data < uBound:
            newArray.append(data)
    return numpy.mean(newArray)

def generateTs(df ,n):
    return t.rvs(df, size=n)


def getTMeans(nSims):
    means100 = []
    means1000 = []
    means10000 = []
    medians100 = []
    medians1000 = []
    medians10000 = []
    trimmedMeans100 = []
    trimmedMeans1000 = []
    trimmedMeans10000 = []
    rootNConsistent = []
    sampleSize = [100, 1000, 10000]
    df = 3
    for nObs in sampleSize:
        for sim in range(0,nSims):
            dataArray = generateTs(df, nObs)
            if nObs == 100:
                means100.append(math.sqrt(len(dataArray))*numpy.mean(dataArray))
                medians100.append(numpy.median(dataArray))
                trimmedMeans100.append(tMean(dataArray, 10))
            elif nObs == 1000:
                means1000.append(numpy.mean(dataArray))
                medians1000.append(numpy.median(dataArray))
                trimmedMeans1000.append(tMean(dataArray, 10))
            else:
                means10000.append(numpy.mean(dataArray))
                medians10000.append(numpy.median(dataArray))
                trimmedMeans10000.append(tMean(dataArray, 10))
                rootNConsistent.append(math.sqrt(len(dataArray))*numpy.mean(dataArray) / math.sqrt(3))
    matrixOfSolutions = {'size100':[means100, medians100, trimmedMeans100],
                         'size1000':[means1000, medians1000,trimmedMeans1000],
                         'size10000':[means10000, medians10000, trimmedMeans10000],
                         'rootN':rootNConsistent}

    return matrixOfSolutions

def createPlots(listOfData):
    """
     For comparison
    """
    tString = "T-Distribution, 3 D.F. "
    fig = pylab.figure()
    gs= gridspec.GridSpec(3,3)

    nBins = 30

    ax1= fig.add_subplot(gs[0,0])
    ax1.set_title(tString+ " Means,\n 100 Obs.")
    ax1.hist(listOfData['size100'][0], bins=nBins)

    ax2= fig.add_subplot(gs[1,0])
    ax2.set_title(tString+ " Medians,\n 100 Obs.")
    ax2.hist(listOfData['size100'][1], bins=nBins)

    ax3= fig.add_subplot(gs[2,0])
    ax3.set_title(tString+ " Trimmed Means,\n 100 Obs.")
    ax3.hist(listOfData['size100'][1], bins=nBins)

    ax4= fig.add_subplot(gs[0,1])
    ax4.set_title(tString+ " Means,\n 1,000 Obs.")
    ax4.hist(listOfData['size1000'][0], bins=nBins)

    ax5= fig.add_subplot(gs[1,1])
    ax5.set_title(tString+ " Medians,\n 1,000 Obs.")
    ax5.hist(listOfData['size1000'][1], bins=nBins)

    ax6= fig.add_subplot(gs[2,1])
    ax6.set_title(tString+ " Trimmed Means,\n 1,000 Obs.")
    ax6.hist(listOfData['size1000'][2], bins=nBins)

    ax7= fig.add_subplot(gs[0,2])
    ax7.set_title(tString+ " Means,\n 10,000 Obs.")
    ax7.hist(listOfData['size10000'][0], bins=nBins)

    ax8= fig.add_subplot(gs[1,2])
    ax8.set_title(tString+ " Medians,\n 10,000 Obs.")
    ax8.hist(listOfData['size10000'][1], bins=nBins)

    ax9= fig.add_subplot(gs[2,2])
    ax9.set_title(tString+ " Trimmed Means,\n 10,000 Obs.")
    ax9.hist(listOfData['size10000'][2], bins=nBins)
    pylab.subplots_adjust(hspace=.75)
    pylab.show()

def empiricalCDFS(dataPassedIn):
    fig = pylab.figure()
    gs= gridspec.GridSpec(2,1)
    ls = numpy.linspace(-6,6)
    trueCDF = fig.add_subplot(gs[0,0])
    trueCDF.plot(t.cdf(ls, 3))
    plot1 = fig.add_subplot(gs[1,0])
    ecdf = scipy.stats.cumfreq(dataPassedIn, 50)
    plot1.plot(ecdf[0])
    pylab.show()


NSIMS = 5000
listOfData = getTMeans(NSIMS)
# createPlots(listOfData)

ls100Means = listOfData['size100'][0]
ls100Medians = listOfData['size100'][1]
ls100TrimmedMeans = listOfData['size100'][2]

ls1000Means = listOfData['size1000'][0]
ls1000Medians = listOfData['size1000'][1]
ls1000TrimmedMeans = listOfData['size1000'][2]

ls10000Means = listOfData['size10000'][0]
ls10000Medians = listOfData['size10000'][1]
ls10000TrimmedMeans = listOfData['size10000'][2]

rootN = listOfData['rootN']

totalData = [ls100Means, ls100Medians, ls100TrimmedMeans, ls1000Means,
             ls1000Medians, ls1000TrimmedMeans, ls10000Means, ls10000Medians,
             ls10000TrimmedMeans, rootN]


# empiricalCDFS(ls100Means)
# empiricalCDFS(ls100Medians)
# empiricalCDFS(ls100TrimmedMeans)
#
# empiricalCDFS(ls1000Means)
# empiricalCDFS(ls1000Medians)
# empiricalCDFS(ls1000TrimmedMeans)
#
# empiricalCDFS(ls10000Means)
# empiricalCDFS(ls10000Medians)
# empiricalCDFS(ls10000TrimmedMeans)




