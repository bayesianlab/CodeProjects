use Securities;


select * 
from (
select max(dt)
from stock_prices
)
where z.rn = 1

