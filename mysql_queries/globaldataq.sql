
select *
from (
	SELECT Country, min(Yr), count(*) Obs
	FROM Securities.recessions
	where GDP is not null
	group by Country) as q
where q.Obs> 250;

create temporary table if not exists Countries as 
(
select Country
from (
SELECT Country, min(Yr), count(*) Cnt 
FROM Securities.recessions
where StockIndex is not null
group by Country ) as Q
where Q.Cnt > 70); 

create table if not exists gdp 
(
select r.*
from Securities.recessions r
join Countries c
	on c.Country=r.Country
where Mon=3 or Mon=6 or Mon=9 or Mon=12); 

-- The earliest year and month to select for the beginning 
select max(Yr), max(Mon)
from (
	select Country, min(Yr) Yr, min(Mon) Mon
	from gdp 
	where GDP is not null
	group by Country
) as q;

select *
from gdp 
where Yr > 2001 and Yr < 2005 
	and Country = 'India';

-- The last possible end date to use for the end 

select  min(Yr), min(Mon)
from
(
	select Country, max(y.Yr) Yr, max(Mon) Mon 
	from 
		(
		select min(Yr) Yr
		from (
			select Country, 
				   max(Yr) Yr
			from gdp 
			where GDP is not null
			group by Country) as q
		) as y 
	join gdp as g
		on g.Yr=y.Yr
	where GDP is not null
	group by Country
) as z 
group by Yr;


select *
from gdp
where Yr<2024 and Yr>2003
	  


select *
from gdp 
where Yr >= 2023 and Mon < 12 and Mon > 1 
	and Country = 'United Kingdom';

select *
from (
SELECT Country, min(Yr), count(*) Cnt 
FROM Securities.recessions
where GDP is not null
group by Country ) as Q
where Q.Cnt > 100;
