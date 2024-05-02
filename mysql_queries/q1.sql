use Securities;
SELECT p.*, s.Sector, s.Security
FROM Securities.stock_prices p
join snp500 as s 
on p.ticker=s.Symbol
where p.ticker='A';


select p.*, daynum, monthnum, yearnum
from 
	(
		select max(dt) dt, 
			   max(Sector) Sector,
               daynum,
               monthnum,
               yearnum
		from 
			(select *,
				   row_number() over(partition by X.daynum, X.monthnum, X.yearnum) as dt_rank
			from 
				(SELECT p.*, 
					   s.Sector, 
					   s.Security, 
					   day(p.dt) daynum, 
					   month(p.dt) monthnum,
					   year(p.dt) yearnum
				FROM Securities.stock_prices p
				join snp500 as s 
				on p.ticker=s.Symbol
				where p.ticker='A') as X) as Y 
		group by Y.daynum, Y.monthnum, Y.yearnum
	) as Z 
join Securities.stock_prices p 
on Z.dt=p.dt
where p.ticker='A';

