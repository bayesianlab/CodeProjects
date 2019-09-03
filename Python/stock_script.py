#!/usr/bin/env python
try:
    # For Python 3.0 and later
    from urllib.request import urlopen
except ImportError:
    # Fall back to Python 2's urllib2
    from urllib2 import urlopen

import json
import pandas as pd

def get_jsonparsed_data(url):
    """
    Receive the content of ``url``, parse it as JSON and return the object.

    Parameters
    ----------
    url : str

    Returns
    -------
    dict
    """
    response = urlopen(url)
    data = response.read().decode("utf-8")
    return json.loads(data)

#example = ("https://financialmodelingprep.com/api/company/profile/AAPL?datatype=json")
#appldict = get_jsonparsed_data(example)
#AAPL = appldict['AAPL']
#print ( AAPL [ 'Price' ] )

symbol_list = "https://financialmodelingprep.com/api/v3/company/stock/list"
all_stocks = get_jsonparsed_data(symbol_list)
print( all_stocks['symbolsList'][0]['symbol'] )
raw = all_stocks['symbolsList']
StockList pd.DataFrame(raw).head()
