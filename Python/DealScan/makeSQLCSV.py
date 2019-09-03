import pandas as pd
import sqlalchemy as sql

searchString = 'select * from FixedRateShareTable{0}'
savePath = 'dealscanSQL/{0}'

def pipeToCSV(conn, sqlSelect, savePath, tableFormatName, csvname):
    df = pd.read_sql(sqlSelect.format(tableFormatName), conn)
    df.to_csv(savePath.format(csvname+'.csv'))
    print(csvname)
    print(df)

eng = sql.create_engine('sqlite:///dealscanSQL/flend.db')
conn = eng.connect()
usaTable = pd.read_sql(searchString.format('USA'), conn)
usaTable.to_csv(savePath.format('usa.csv'))
print(usaTable)

notUsaTable = pd.read_sql(searchString.format('NotUSA'), conn)
notUsaTable.to_csv(savePath.format('notusa.csv'))
print(notUsaTable)

less50 = pd.read_sql(searchString.format('Less50'), conn)
less50.to_csv(savePath.format('less50.csv'))
print(less50)

more50 = pd.read_sql(searchString.format('More50'), conn)
more50.to_csv(savePath.format('more50.csv.quit.quit'))
print(more50)

corpPurposes = pd.read_sql(searchString.format('CorpPurposes'), conn)
corpPurposes.to_csv(savePath.format('corpPurposes.csv'))
print(corpPurposes)

workCap = pd.read_sql(searchString.format('WorkCap'), conn)
workCap.to_csv(savePath.format('workCap.csv'))
print(workCap)

tradeFinance = pd.read_sql(searchString.format('TradeFinance'), conn)
tradeFinance.to_csv(savePath.format('tradeFinance.csv'))
print(tradeFinance)

debtRepay = pd.read_sql(searchString.format('DebtRepay'), conn)
debtRepay.to_csv(savePath.format('debtRepay.csv'))
print(debtRepay)
print('debt repay')


realEstate = pd.read_sql(searchString.format('RealEstate'), conn)
realEstate.to_csv(savePath.format('realEstate.csv'))
print('realestate')
print(realEstate)

takeOverLBO = pd.read_sql(searchString.format('TakeOverLBO'), conn)
takeOverLBO.to_csv(savePath.format('takeOverLBO.csv'))
print('takeover lbo')
print(takeOverLBO)

# salesNull = pd.read(searchString.format('SalesNull'), conn)
# salesNull.to_csv(savePath.format('salesNull'))
# print('salesnull')
# print(salesNull)
pipeToCSV(conn, searchString, savePath, 'SalesNull', 'salesNull')
pipeToCSV(conn, searchString, savePath, 'Sales', 'sales')
pipeToCSV(conn, searchString, savePath, 'SalesLowerQ', 'salesLowerQ')
pipeToCSV(conn, searchString, savePath, 'SalesSecondQ', 'salesSecondQ')
pipeToCSV(conn, searchString, savePath, 'SalesThirdQ', 'salesThirdQ')
pipeToCSV(conn, searchString, savePath, 'SalesFourthQ', 'salesFourthQ')