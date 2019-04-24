
from bs4 import BeautifulSoup as bs
import pandas as pd


page = 'http://canadianwarrants.com/american/nasdaq.html#axzz5lr53Lebp'
frame =pd.read_html(page, skiprows=3, header=0)[0]
frame.rename(columns={'Unnamed: 0': 'CompanyName'}, inplace=True)
print(frame.columns)
print('Program Terminated')
