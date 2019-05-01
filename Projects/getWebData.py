
from bs4 import BeautifulSoup as bs
import pandas as pd


page = 'http://canadianwarrants.com/american/nasdaq.html#axzz5lr53Lebp'
table =pd.read_html(page, skiprows=3, header=0)[0]
table.rename(columns={'Unnamed: 0': 'CompanyName', 'Stock':'StockSymbol', 
                      'US$': 'ExercisePrice', 'Symbol.1':'WarrantSymbol', 
                      'Date':'ExpirationDate'}, inplace=True)
print(table.columns)
print(table[['CompanyName', 'StockSymbol', 'WarrantSymbol', 'ExpirationDate', 
             'Common', 'ExercisePrice', 'Price']].head(10))
print('Program Terminated')
