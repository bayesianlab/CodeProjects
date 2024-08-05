use Securities; 

-- drop table GlobalRecessions
select max(mindt) 
from (
select Country, min(Dt) mindt
from GlobalRecessions
where RecessionIndicator is not null
group by Country) q;

-- 1996-05-01 max min dt 
select *
from (
select Country, max(Dt) as maxdt 
from GlobalRecessions 
where RecessionIndicator is not null 
group by Country) a
join (select min(maxdt) minimax
from (
select Country, max(Dt) as maxdt 
from GlobalRecessions 
where RecessionIndicator is not null 
group by Country) b
where maxdt='2017-11-01') c 
on c.minimax=a.maxdt;
-- Exclude New Zealand 

select min(maxdt)
from (
select Country, max(Dt) as maxdt 
from GlobalRecessions 
where RecessionIndicator is not null and Country<>'New Zealand' 
group by Country) b
where maxdt > '2022-01-01';

-- '2022-05-01'

-- drop table RecessionData
create temporary table if not exists RecessionData as (
select *
from GlobalRecessions 
where Dt>='1996-05-01' and Dt <= '2022-05-01'
	and Country<>'New Zealand' 
    and Country<>'Russia'
    and Country<>'Luxembourg'
    and Country<> 'Turkey'
    and Country<>'India'
    and Country<>'Indonesia'); 

select Country ,count(*), min(Dt), max(Dt)
from RecessionData
where RecessionIndicator is not null
group by Country;

-- data is good 
-- drop table ProbitData
create table if not exists ProbitData as (
select Dt, RecessionIndicator as Ri, Country, CountryCode, GDP, StockIndex, Qrtr, Yr, Mon
from (
	select Dt, RecessionIndicator, a.Country, a.CountryCode, GDP, IndustrialProd, StockIndex,
           case when a.Mon = 3 then 1
				when a.Mon = 6 then 2
				when a.Mon = 9 then 3
				when a.Mon = 12 then 4
			 end as Qrtr, 
             a.Yr, 
             a.Mon
	from (select *, year(Dt) as Yr, month(Dt) as Mon
		  from RecessionData d) a 
	join recessions r on r.Country=a.Country 
		and r.Yr=a.Yr and r.Mon=a.Mon ) b 
where Qrtr is not null
	and Dt > '1998-12-01');

select  Country, count(*) - count(GDP) NumNullsGDP,
	   count(*) - count(StockIndex) NumNullsStocks
from ProbitData
group by Country ;

select *
from ProbitData
order by Yr, Mon, Country 














