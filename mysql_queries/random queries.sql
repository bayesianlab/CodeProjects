use Securities;


select dt, ticker, adj_close
from stock_prices
where dt=(select max(dt) from stock_prices)
order by adj_close

