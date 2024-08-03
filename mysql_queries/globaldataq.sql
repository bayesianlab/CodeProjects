use Securities; 
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

select *
from gdp

-- The earliest year and month to select for the beginning 
select max(Yr), max(Mon)
from (
	select Country, min(Yr) Yr, min(Mon) Mon
	from gdp 
	where GDP is not null
	group by Country
) as q;

-- The last possible end date to use for the end 
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
group by Country;

-- drop table gdp2
create table if not exists gdp2
(
select *, row_number() over (partition by Country order by Yr, mon) rn
from gdp
where Yr>=2004 
and Yr<=2023 
and Country <>'Mexico' 
);

select Country, rn
from gdp2
where GDP is null;

select *
from gdp2 
where rn > 1 and rn < 79



 

