import pandas as pd
import sqlalchemy as sql

eng = sql.create_engine('sqlite:///flend.db')
conn = eng.connect()

relF = pd.read_sql('select * from relationshipsWithFixedRates', conn)
relF.to_csv('rel_fix.csv')