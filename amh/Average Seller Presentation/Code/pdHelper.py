import math
import numpy as np
import pandas as pd
from functools import partial
import pyodbc
import datetime
import matplotlib.pyplot as plt
from statsmodels.stats.weightstats import DescrStatsW
from pandas import ExcelWriter
import calendar
import warnings 
warnings.filterwarnings('ignore')
def savitzky_golay(y, window_size, order, deriv=0, rate=1):
    r"""Smooth (and optionally differentiate) data with a Savitzky-Golay filter.
    The Savitzky-Golay filter removes high frequency noise from data.
    It has the advantage of preserving the original shape and
    features of the signal better than other types of filtering
    approaches, such as moving averages techniques.
    Parameters
    ----------
    y : array_like, shape (N,)
        the values of the time history of the signal.
    window_size : int
        the length of the window. Must be an odd integer number.
    order : int
        the order of the polynomial used in the filtering.
        Must be less then `window_size` - 1.
    deriv: int
        the order of the derivative to compute (default = 0 means only smoothing)
    Returns
    -------
    ys : ndarray, shape (N)
        the smoothed signal (or it's n-th derivative).
    Notes
    -----
    The Savitzky-Golay is a type of low-pass filter, particularly
    suited for smoothing noisy data. The main idea behind this
    approach is to make for each point a least-square fit with a
    polynomial of high order over a odd-sized window centered at
    the point.
    Examples
    --------
    t = np.linspace(-4, 4, 500)
    y = np.exp( -t**2 ) + np.random.normal(0, 0.05, t.shape)
    ysg = savitzky_golay(y, window_size=31, order=4)
    import matplotlib.pyplot as plt
    plt.plot(t, y, label='Noisy signal')
    plt.plot(t, np.exp(-t**2), 'k', lw=1.5, label='Original signal')
    plt.plot(t, ysg, 'r', label='Filtered signal')
    plt.legend()
    plt.show()
    References
    ----------
    .. [1] A. Savitzky, M. J. E. Golay, Smoothing and Differentiation of
       Data by Simplified Least Squares Procedures. Analytical
       Chemistry, 1964, 36 (8), pp 1627-1639.
    .. [2] Numerical Recipes 3rd Edition: The Art of Scientific Computing
       W.H. Press, S.A. Teukolsky, W.T. Vetterling, B.P. Flannery
       Cambridge University Press ISBN-13: 9780521880688
    """
    import numpy as np
    from math import factorial
    
    try:
        window_size = np.abs(np.int(window_size))
        order = np.abs(np.int(order))
    except ValueError:
        raise ValueError("window_size and order have to be of type int")
    if window_size % 2 != 1 or window_size < 1:
        raise TypeError("window_size size must be a positive odd number")
    if window_size < order + 2:
        raise TypeError("window_size is too small for the polynomials order")
    order_range = range(order+1)
    half_window = (window_size -1) // 2
    # precompute coefficients
    b = np.mat([[k**i for i in order_range] for k in range(-half_window, half_window+1)])
    m = np.linalg.pinv(b).A[deriv] * rate**deriv * factorial(deriv)
    # pad the signal at the extremes with
    # values taken from the signal itself
    firstvals = y[0] - np.abs( y[1:half_window+1][::-1] - y[0] )
    lastvals = y[-1] + np.abs(y[-half_window-1:-1][::-1] - y[-1])
    y = np.concatenate((firstvals, y, lastvals))
    return np.convolve( m[::-1], y, mode='valid')

def sortPdColumns(pdData):
    return pdData.reindex_axis(sorted(pdData.columns), axis=1)

def readCsvFiles(csvFileNameList,skiprows=0,dtype=None):
    """
    read multiple csv files 
    parameter: csvFileNameList=['a.csv','c:\test.csv']
    return a data frame
    """

    data=None
    for f in csvFileNameList:
        if dtype is None:
            thisData=pd.read_csv(f,sep=',',skiprows=skiprows)
        else:
            thisData=pd.read_csv(f,sep=',',skiprows=skiprows,dtype=dtype)
        if data is None:
            data=thisData
        else:
            data=pd.concat([data,thisData])
    return data

def formatPd(floatFormat='{:,.2f}'):
    """
    '{:,.2%}'
    '{:,.0f}'
    """
    pd.options.display.float_format = floatFormat.format

def modifyCsvFiles(csvFileNameList,columnList,columnValList,newCsvFileNameList):
    """
    modify all csv files' columnList to have columnValList
    if a column doesn't exist, the new column will be added
    """
    
    for j in range(len(csvFileNameList)):
        f=csvFileNameList[j]
        data=pd.read_csv(f,sep=',')
        for i in range(len(columnList)):
            data[columnList[i]]=columnValList[i]
        print('write csv file '+newCsvFileNameList[j])
        data.to_csv(newCsvFileNameList[j],index=False)



def addMonths(sourcedate,months):
    month = sourcedate.month - 1 + months
    year = int(sourcedate.year + month / 12 )
    month = month % 12 + 1
    day = min(sourcedate.day,calendar.monthrange(year,month)[1])
    return datetime.date(year,month,day)


def getFormattedPd(originalPd,columnList,formatList):
    """
    format examples: {:,.0f}.format
    """
    pd=originalPd.copy()#deep copy
    for i in range(len(columnList)):
        pd[columnList[i]]=pd[columnList[i]].map(formatList[i])
    pd=pd.style.set_properties(**{'text-align': 'right'})
    return pd

    
def showPd(max_columns=None,max_rows=None):
    pd.options.display.max_columns=max_columns
    pd.options.display.max_rows=max_rows

def changeDisplayWidth(width):
    pd.set_option('display.width',300)

def summary(df, fn=np.sum, axis=0, name='Total',  
            table_class_prefix='dataframe-summary'):
    """Append a summary row or column to DataFrame.

    Input:
    ------
    df : Dataframe to be summarized
    fn : Summary function applied over each column
    axis : Axis to summarize on (1: by row, 0: by column)
    name : Index or column label for summary
    table_class_prefix : Custom css class for dataframe

    Returns:
    --------
    Dataframe with applied summary.

    """
    total = df.apply(fn, axis=axis).to_frame(name)

    table_class = ""

    if axis == 0:
        total = total.T
        table_class = "{}-row".format(table_class_prefix)
    elif axis == 1:
        table_class = "{}-col".format(table_class_prefix)

    out = pd.concat([df, total], axis=axis)
    # Patch to_html function to use custom css class
    out.to_html = partial(out.to_html, classes=table_class)
    return out

def getMax(df,ignoreColList):
    maxVal=None
    for c in df.columns:
        if c not in ignoreColList:
            values=df[c].values
            if maxVal is None:
                maxVal=max(values)
            elif max(values)>maxVal:
                maxVal=max(values)
    return maxVal


def sliceData(df,givenFieldList,givenValueList):
    sample=df.copy()
    for i in range(len(givenFieldList)):
        sample=sample.loc[sample[givenFieldList[i]]==givenValueList[i],]
    return sample



def sliceDataPivot(df,givenFieldList,givenValueList,pivotField,x,y):
    sample=sliceData(df,givenFieldList,givenValueList)
    uniquePivotFields=np.unique(sample[pivotField])
    uniquePivotFields.sort()
    cuts=None
    for i in range(len(uniquePivotFields)):
        cut=sample.loc[sample[pivotField]==uniquePivotFields[i],[x,y]]
        cut=cut.copy()
        cut.columns=[x,str(uniquePivotFields[i])]
        cut=cut.set_index(x)
        cut=cut.sort_index()
        if(cuts is None):
            cuts=cut
        else:
            cuts=pd.concat([cuts,cut],axis=1)
    return cuts


# In[36]:

import numpy as np 
import pandas as pd 
import itertools

def cartesian(df1, df2):
    rows = itertools.product(df1.iterrows(), df2.iterrows())
    df = pd.DataFrame(left.append(right) for (_, left), (_, right) in rows)
    return df.reset_index(drop=True)


# In[38]:

def selectData(query,database='Market',server='usersql'):
    conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+database+ ';trusted_connection=yes')
    return pd.read_sql(query,conn)

def getQtrStrFromDt(myDateTime):
    return str(myDateTime.year)+'Q'+str(math.ceil(myDateTime.month/3))

def getQtrDtFromDt(dt):
    if dt.month<4:
        return datetime.datetime(dt.year,1,1)
    elif dt.month<7:
        return datetime.datetime(dt.year,4,1)
    elif dt.month<10:
        return datetime.datetime(dt.year,7,1)
    else:
        return datetime.datetime(dt.year,10,1)

def getQtrStr(qtrStr,offSet):
    result=qtrStr
    if (offSet>=0):
        for i in range((offSet)):
            if 'Q4' in result:
                result= str(int(result[:4])+1)+'Q1'
            else:
                result= result[:4]+'Q'+str(int(result[-1])+1)
    else:
        for i in range(-(offSet)):
            if 'Q1' in result:
                result= str(int(result[:4])-1)+'Q4'
            else:
                result= result[:4]+'Q'+str(int(result[-1])-1)
    return result

def getQtrDtFromQtrDtStr(qtrDtStr):
    qtrDtVal=None
    if len(qtrDtStr)!=6:
        raise ValueError('Invalid input of qtrStr!')
    if qtrDtStr[-2:]=="Q1":
            qtrDtVal=datetime.date(int(qtrDtStr[:4]),1,1)
    elif qtrDtStr[-2:]=="Q2":
            qtrDtVal=datetime.date(int(qtrDtStr[:4]),4,1)
    elif qtrDtStr[-2:]=="Q3":
            qtrDtVal=datetime.date(int(qtrDtStr[:4]),7,1)
    elif qtrDtStr[-2:]=="Q4":
            qtrDtVal=datetime.date(int(qtrDtStr[:4]),10,1)
    else:
        raise ValueError('Invalid input of qtrStr!')
    return qtrDtVal

def insertData(pandasData,tableName,database='Scratch',server='prdsql',if_exists='append'):
    """
    if_exists: fail, replace, append
    """
    from sqlalchemy import create_engine
    import urllib.parse 
    connection_string = "DRIVER={SQL Server};Database="+database+";SERVER="+server+";"
    connection_string = urllib.parse.quote_plus(connection_string) 
    connection_string = "mssql+pyodbc:///?odbc_connect=%s" % connection_string
    engine=create_engine(connection_string)
    pandasData.to_sql(tableName,engine,schema='dbo',index=False,if_exists=if_exists)



def execQuery(query,database='Market',server='usersql'):
    conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+database+';trusted_connection=yes')
    cursor = conn.cursor()
    cursor.execute(query)
    conn.commit()

def getSeconds(t):
    return (t-datetime.datetime(1970,1,1)).total_seconds()


def getExcelOaDt(pythonDt):
    temp = datetime.date(1899, 12, 30)    # Note, not 31st Dec but 30th!
    delta = pythonDt - temp
    return float(delta.days) + (float(delta.seconds) / 86400)

def sortPd(data,columnName):
    data=data.reset_index()
    data=data.set_index(columnName)
    data=data.sort_index()
    data=data.reset_index()
    return data


def histPd(data,cutColName,cutUpperBoundList,valColName):
    plt.close('all')
    for i in range(len(cutUpperBoundList)):
        cut=data.loc[data[cutColName]<=cutUpperBoundList[i],]
        if i>0:
            cut=cut.loc[data[cutColName]>cutUpperBoundList[i-1],]
        plt.figure()
        cut[valColName].hist(bins=100)


# In[73]:

def wtdAvg(pandas,valueForWeightColList,weightColName,reportSumColList):
    """
    valueForWeightColList=['Px','Oas']
    weightColName='UPB'
    reportSumColList=['UPB','Val']
    """
    w = pandas[weightColName]
    result=pd.Series({'Sum'+weightColName:w.sum(),'Cnt':len(pandas)})
    for i in range(len(reportSumColList)):
        if reportSumColList[i] !=weightColName:
            result=result.append(pd.Series({'Sum'+reportSumColList[i]:pandas[reportSumColList[i]].sum()}))
            
    for i in range(len(valueForWeightColList)):
            
        weighted_stats = DescrStatsW(pandas[valueForWeightColList[i]].values, weights=w.values/(w.values.sum()), ddof=0)
        avg=weighted_stats.mean
        stdev=weighted_stats.std
        if(len(pandas[valueForWeightColList[i]])==1):
            avg=pandas[valueForWeightColList[i]].values[0]
            stdev=0
        thisSeries= pd.Series({'Avg'+valueForWeightColList[i]:avg,'Stdev'+valueForWeightColList[i]:stdev})
        result=result.append(thisSeries)
    return result
        


def groupByWtdAvg(pandas,groupByCols,valueForWeightColList,weightColName,reportSumColList):
    group=pandas.groupby(groupByCols)
    return group.apply(lambda x: wtdAvg(x,valueForWeightColList,weightColName,reportSumColList))

def plotHist(listOfData,seriesNameList,seriesColorList,minX,maxX,step,overlap=False,histtype='step',normed=False):
    """
    histtype: step, stepfilled, bar
    """
    bins = np.arange(minX,maxX+step,step)
    if overlap:
        for i in range(len(listOfData)):
            print("color: {0}".format(seriesColorList[i]))
            plt.hist(listOfData[i], bins, alpha=0.7, label=seriesNameList[i],histtype =histtype,align='mid',normed=normed,color=seriesColorList[i])
        plt.legend(loc='upper right')
    else:
        data = np.vstack(listOfData).T
        print("color: {0}".format(seriesColorList[i]))
        plt.hist(data, bins, alpha=0.7, label=seriesNameList,histtype =histtype,align='mid',normed=normed,color=seriesColorList[i])
        plt.legend(loc='upper right')


def monthDiff(startDt, endDt):
    return (endDt.year - startDt.year)*12 + endDt.month - startDt.month

def getFicoGrp(fico):
    if fico <= 580:
        return 580
    elif fico <= 820:
        return math.ceil(fico / 20) * 20
    else:
        return 840

def getLtvGrp(ltv):
    if ltv <= 20:
        return 20
    elif ltv<=30:
        return 30
    elif ltv<=40:
        return 40
    elif ltv<=50:
        return 50
    elif ltv<=60:
        return 60
    elif ltv <= 75:
        return 75
    elif ltv <= 80:
        return 80
    elif ltv <= 90:
        return 90
    elif ltv <= 95:
        return math.ceil(ltv / 5) * 5
    elif ltv <= 96.5:
        return 96.5
    elif ltv<=100:
        return 100
    else:
        return 105

def getLoanAmtGrp(loanAmt):
    if loanAmt <= 20000:
            return 20000
    elif loanAmt <= 40000:
        return 40000
    elif loanAmt <= 60000:
        return 60000
    elif loanAmt <= 80000:
        return 80000
    elif loanAmt <= 100000:
        return 100000
    elif loanAmt <= 140000:
        return 140000
    elif loanAmt <= 180000:
        return 180000
    elif loanAmt <= 220000:
        return 220000
    elif loanAmt <= 260000:
        return 260000
    elif loanAmt <= 300000:
        return 300000
    elif loanAmt <= 400000:
        return 400000
    elif loanAmt <= 500000:
        return 500000
    else:
        return 600000


