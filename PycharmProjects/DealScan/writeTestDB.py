import pandas as pd
import sqlalchemy as sql

eng = sql.create_engine('sqlite:///testdb.db')
con = eng.connect()
# a = pd.DataFrame({ 'PackageID':[10,10,20,20,20,20,30,30,30,40], 'BorrowerID':[1,1,2,2,2,2,3,3,3,1], 'CompanyID':[100,200,300,300,400,100,400,100,200,100]})
# print(a)
# a.to_sql('testdb', con, if_exists='replace')

eng = sql.create_engine('sqlite:///testdb2.db')
con = eng.connect()
testdb2 = pd.read_csv('testdb2.csv')
testdb2.to_sql('testdb2', con, if_exists='replace')

eng = sql.create_engine('sqlite:///testdb3.db')
con = eng.connect()
testdb2 = pd.read_csv('testdb3.csv')
testdb2.to_sql('testdb3', con, if_exists='replace')