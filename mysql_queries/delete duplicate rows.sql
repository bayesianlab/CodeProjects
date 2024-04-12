SET SQL_SAFE_UPDATES = 0;
use Securities;

delete from stock_prices
where id in 
(
	select id 
	from 
		(select id, row_number() over(partition by dt, ticker order by dt) as rn 
		from stock_prices) z
	where rn > 1
);

select * 
from stock_prices;