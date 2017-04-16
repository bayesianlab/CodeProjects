import pandas as pd
import sqlalchemy as sql




eng = sql.create_engine('sqlite:///dealscanDatabase.db')
conn = eng.connect()

# facility = pd.read_csv('facility.csv')
# facility.to_sql('facility', conn, if_exists='replace')


# package =pd.read_csv('package.csv')
# package.to_sql('package', conn, if_exists='replace')

# fac_price = pd.read_csv('current_facility_pricing.csv')
# fac_price.to_sql('fac_price', conn, if_exists='replace')

# lenders = pd.read_csv('lenders.csv')
# lenders.to_sql('lenders', conn, if_exists='replace')


print('DONE!')