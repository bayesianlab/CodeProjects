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

class CauchyStuff():

    def __init__(self):
        self.means100 = []
        self.medians100 = []
        self.trimmedMeans100 = []

        self.means1000 = []
        self.medians1000 = []
        self.trimmedMeans1000 = []

        self.means10000 = []
        self.medians10000 = []
        self.trimmedMeans10000 = []
        self.rootNConsistent = []

        self.allStats = [self.means100, self.medians100, self.trimmedMeans100, self.means1000,
                         self.medians1000, self.trimmedMeans1000, self.means10000, self.medians10000,
                         self.trimmedMeans10000, self.rootNConsistent]


    def tMean(self, array, trim):
        newArray = []
        upperPercentile = 100 - (trim/2.0)
        lowerPercentile = trim/2.0
        lBound =  numpy.percentile(array, lowerPercentile)
        uBound = numpy.percentile(array, upperPercentile)
        for data in array:
            if data > lBound and data < uBound:
                newArray.append(data)
        return numpy.mean(newArray)

    def monteCarlo(self, nSims):
        for i in range(nSims):
            cauchy100 = numpy.random.standard_cauchy(100)
            cauchy1000 = numpy.random.standard_cauchy(1000)
            cauchy10000 = numpy.random.standard_cauchy(10000)
            self.means100.append(numpy.mean(cauchy100))
            self.medians100.append(numpy.median(cauchy100))
            self.trimmedMeans100.append(self.tMean(cauchy100, 10))

            self.means1000.append(numpy.mean(cauchy1000))
            self.medians1000.append(numpy.median(cauchy1000))
            self.trimmedMeans1000.append(self.tMean(cauchy1000, 10))

            self.means10000.append(numpy.mean(cauchy10000))
            self.medians10000.append(numpy.median(cauchy10000))
            self.trimmedMeans10000.append(self.tMean(cauchy10000, 10))

            self.rootNConsistent.append((math.sqrt(len(cauchy10000))*numpy.mean(cauchy10000))/
                                         numpy.std(cauchy10000))

    def setUpPlots(self, fig, gs, dist):
        subplotList = []
        observation100String = dist + ",\n 100 Obs"
        observation1000String = dist + ",\n 1,000 Obs"
        observation10000String = dist + ",\n 10,000 Obs"
        for j in range(3):
            for i in range(3):
                if j == 0:
                    subplotList.append(fig.add_subplot(gs[i, j]).set_title(observation100String + ' Means'))
                    subplotList.append(fig.add_subplot(gs[i+1, j]).set_title(observation100String + ' Medians'))
                    subplotList.append(fig.add_subplot(gs[i+2, j]).set_title(observation100String + ' Trimmed Means'))
                    break
                elif j == 1:
                    subplotList.append(fig.add_subplot(gs[i, j]).set_title(observation1000String +
                                                                           ' Means'))
                    subplotList.append(fig.add_subplot(gs[i+1, j]).set_title(observation1000String +
                                                                             'Medians'))
                    subplotList.append(fig.add_subplot(gs[i+2, j]).set_title(observation100String +
                                                                             ' Trimmed Means'))
                    break
                else:
                    subplotList.append(fig.add_subplot(gs[i, j]).set_title(observation10000String+ ' Means'))
                    subplotList.append(fig.add_subplot(gs[i+1, j]).set_title(observation100String +
                                                                             ' Medians'))
                    subplotList.append(fig.add_subplot(gs[i+2, j]).set_title(observation100String +
                                                                             ' Trimmed Means'))
                    break
        return subplotList

    def createPlots(self, dist):
        fig = pylab.figure()
        gs = gridspec.GridSpec(3,3)
        nBins = 30
        subplots = self.setUpPlots(fig,gs, dist)
        for j in range(3):
            for i in range(3):
                if j == 0:
                    fig.add_subplot(gs[i,j]).hist(self.means100, bins=nBins)
                    fig.add_subplot(gs[i+1,j]).hist(self.medians100, bins=nBins)
                    fig.add_subplot(gs[i+2,j]).hist(self.trimmedMeans100, bins=nBins)
                    break
                elif j == 1:
                    fig.add_subplot(gs[i,j]).hist(self.means1000, bins=nBins)
                    fig.add_subplot(gs[i+1,j]).hist(self.medians1000, bins=nBins)
                    fig.add_subplot(gs[i+2,j]).hist(self.trimmedMeans1000, bins=nBins)
                    break
                else:
                    fig.add_subplot(gs[i,j]).hist(self.means10000, bins=nBins)
                    fig.add_subplot(gs[i+1,j]).hist(self.medians10000, bins=nBins)
                    fig.add_subplot(gs[i+2,j]).hist(self.trimmedMeans10000, bins=nBins)
                    break
        pylab.subplots_adjust(hspace=.50)


    def plotCDFs(self):
        ls = numpy.linspace(-30,30)
        trueCDF = scipy.stats.cauchy.cdf(ls)
        fig1 = pylab.figure()
        ax1 = pylab.subplot(411)
        ax2 = pylab.subplot(412)
        ax3 = pylab.subplot(413)
        ax4 = pylab.subplot(414)
        ax1.plot(trueCDF)
        ax1.set_title("Theoretical CDF")
        ax2.plot(scipy.stats.cumfreq(self.means100)[0])
        ax2.set_title("100 Obs Mean ECDF")
        ax3.plot(scipy.stats.cumfreq(self.medians100)[0])
        ax3.set_title("100 Obs Median ECDF")
        ax4.plot(scipy.stats.cumfreq(self.trimmedMeans100)[0])
        ax4.set_title("100 Obs Trimmed Mean ECDF")

        fig2 = pylab.figure()
        ax1 = pylab.subplot(411)
        ax2 = pylab.subplot(412)
        ax3 = pylab.subplot(413)
        ax4 = pylab.subplot(414)
        ax1.plot(trueCDF)
        ax1.set_title("Theoretical CDF")
        ax2.plot(scipy.stats.cumfreq(self.means1000)[0])
        ax2.set_title("1000 Obs Mean ECDF")
        ax3.plot(scipy.stats.cumfreq(self.medians1000)[0])
        ax3.set_title("1000 Obs Median ECDF")
        ax4.plot(scipy.stats.cumfreq(self.trimmedMeans1000)[0])
        ax4.set_title("1000 Obs Trimmed Mean ECDF")

        fig3 = pylab.figure()
        ax1 = pylab.subplot(411)
        ax2 = pylab.subplot(412)
        ax3 = pylab.subplot(413)
        ax4 = pylab.subplot(414)
        ax1.plot(trueCDF)
        ax1.set_title("Theoretical CDF")
        ax2.plot(scipy.stats.cumfreq(self.means10000)[0])
        ax2.set_title("10000 Obs Mean ECDF")
        ax3.plot(scipy.stats.cumfreq(self.medians10000)[0])
        ax3.set_title("10000 Obs Median ECDF")
        ax4.plot(scipy.stats.cumfreq(self.trimmedMeans10000)[0])
        ax4.set_title("10000 Obs Trimmed Mean ECDF")
        pylab.subplots_adjust(hspace=.75)

class WeridNormal(CauchyStuff):

    def monteCarlo(self, nSims):
        mean = 0
        var1 = 1
        var2 = 400
        for i in range(nSims):
            weirdNormal100= numpy.random.normal(mean, var1, 90)
            weirdNormal100 = numpy.append(weirdNormal100, numpy.random.normal(mean, var2, 10))
            weirdNormal1000 = numpy.random.normal(mean, var1, 900)
            weirdNormal1000 = numpy.append(weirdNormal1000, numpy.random.normal(mean, var2, 100))
            weirdNormal10000 = numpy.random.normal(mean, var1, 9000)
            weirdNormal10000 = numpy.append(weirdNormal10000, numpy.random.normal(mean, var2, 1000))

            self.means100.append(numpy.mean(weirdNormal100))
            self.medians100.append(numpy.median(weirdNormal100))
            self.trimmedMeans100.append(self.tMean(weirdNormal100, 10))

            self.means1000.append(numpy.mean(weirdNormal100))
            self.medians1000.append(numpy.median(weirdNormal1000))
            self.trimmedMeans1000.append(self.tMean(weirdNormal1000, 10))

            self.means10000.append(numpy.mean(weirdNormal10000))
            self.medians10000.append(numpy.median(weirdNormal10000))
            self.trimmedMeans10000.append(self.tMean(weirdNormal10000, 10))

            self.rootNConsistent.append(math.sqrt(len(weirdNormal10000))*numpy.mean(weirdNormal10000))











