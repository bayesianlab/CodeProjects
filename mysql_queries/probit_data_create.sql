use Securities; 

-- drop table ProbitData
-- drop table gdp
-- drop table recessions
create  table if not exists gdp(
	Country varchar(64),
	CountryCode varchar(8),
	Yr int,
	Mon int,
	GDP decimal(14,5),
	IndustrialProd decimal(14,5),
	Investment decimal (14,5),
	Employment	decimal(14,5),
    StockIndex decimal(14,5));
    
SET SQL_SAFE_UPDATES = 0;
update gdp 
set GDP = 7588.0404 
where Yr=2023 and Mon=6
	and Country='Mexico';
    
    
update gdp
set GDP=7671.508
	where Yr=2023 and Mon=9
    and Country='Mexico';
    
update gdp
set GDP=7679.18
	where Yr=2023 and Mon=12
    and Country='Mexico';
    
update gdp
set GDP=667.062
	where Yr=2023 and Mon=9
    and Country='United Kingdom';

update gdp
set GDP=665.06
	where Yr=2023 and Mon=12
    and Country='United Kingdom';


    
-- drop table qrtgdp
create temporary table if not exists qrtgdp as (
select *, convert(concat(concat(Yr, '-', Mon), '-', '01'), date) as Dt
from gdp 
where Mon in (3,6,9,12)
);


-- drop table GlobalRecessions
create table if not exists GlobalRecessions(
	Dt date null,
    RecessionIndicator int null,
    CountryCode varchar(8),
    SeriesId varchar(16),
    Country varchar(128)
);
-- select * from GlobalRecessions

-- drop table Countries
create temporary table if not exists Countries as (
select row_number() over(order by Country) as CountryId,  Country,  max(CountryCode) CountryCode
from GlobalRecessions q
where q.CountryCode <> 'IND' 
    and q.CountryCode <> 'NZL'
    and q.CountryCode <> 'LUX'
    and q.CountryCode <> 'ZAF'
    and q.CountryCode <> 'IDN'
group by Country); 


-- drop table QuarterlyGdp
create temporary table if not exists QuarterlyGdp as (
select q.Country, q.CountryCode, q.Dt, q.GDP, q.StockIndex
from qrtgdp q
join Countries g
	on g.CountryCode=q.CountryCode
where q.Dt > '1997-01-03'
order by q.Country, q.Dt);


-- drop table gdp 
-- drop table gdp2
-- drop table GlobalRecessions


-- drop table QuarterlyRecessionData
create temporary table if not exists QuarterlyRecessionData as(
select *
from (select *, year(Dt) as Yr, month(Dt) as Mon
	from GlobalRecessions) q
where Mon in (3,6,9, 12));

-- drop table InSample
create temporary table if not exists TempInSample as (
select q.Dt, q.RecessionIndicator, 
	q.CountryCode, q.Country, q.Yr, q.Mon,
    g.GDP, g.StockIndex, row_number() over (partition by q.Country order by Dt)
from QuarterlyRecessionData q
join qrtgdp g
	on g.Yr=q.Yr and g.Mon=q.Mon and g.Country=q.Country
    and q.CountryCode <> 'IND' 
    and q.CountryCode <> 'NZL'
    and q.CountryCode <> 'LUX'
    and q.CountryCode <> 'ZAF'
    and q.CountryCode <> 'IDN' 
    and q.CountryCode <> 'RUS'
where q.Yr > 1997 and 
	q.Dt <= '2022-06-01'); 
    
create temporary table if not exists TempInSample2 as(
select * from TempInSample
); 

-- drop table GrowthRateProbitData;
create temporary table if not exists TempGrateInSample as(
select cur.Dt,
	   cur.Yr,
       cur.Mon,
	   cur.Country,
       log(cur.GDP/lag1.GDP) as GDPGrowth, 
       log(cur.StockIndex/lag1.StockIndex) as ExpRet,
       cur.RecessionIndicator
from(select Dt, Country, Yr, Mon, GDP, StockIndex, RecessionIndicator, 
			row_number() over(partition by Country order by Dt) +1 as rn
	from TempInSample
	where Dt >= '1998-03-01') lag1
join (select Dt, Country, Yr, Mon, GDP, StockIndex, RecessionIndicator, 
		     row_number() over(partition by Country order by Dt) rn
	  from TempInSample2
	  where Dt <= '2022-06-01') cur
on lag1.rn=cur.rn
and lag1.Country=cur.Country
);

create temporary table if not exists TempGrateInSample2 (
	select *
	from TempGrateInSample
);

-- drop table DataLagged
create table if not exists Insample as (
select b.Dt, b.Country, b.RecessionIndicator, b.GDPGrowth, b.ExpRet
from (
	  select *, row_number() over (partition by Country order by Dt) + 1 rn
	  from TempGrateInSample
      ) q
join (select *, row_number() over(partition by Country order by Dt) rn from TempGrateInSample2) b 
	on b.rn=q.rn
		and b.Country=q.Country
order by q.Country, q.Dt); 
   
-- drop table grdate   
create temporary table if not exists grdate as (
select *, convert(concat(concat(Yr, '-', Mon), '-', '01'), date) as Dt
from gdp
where Yr > 1997
);

-- drop table g1
create temporary table if not exists g1 as (
select g.Country, g.CountryCode, Dt, GDP, StockIndex,
		row_number() over(partition by Country order by Dt) + 1 rn 
from grdate g
join Countries c on c.Country=g.Country
where Mon in (3,6,9,12) 
); 

-- drop table g2
create temporary table if not exists g2 as (
select g.Country, g.CountryCode, Dt, GDP, StockIndex,
		row_number() over(partition by Country order by Dt) rn
from grdate g
join Countries c on c.Country=g.Country
where Mon in (3,6,9,12) 
); 


create table if not exists OutSample as (
select g2.Country, g2.CountryCode, g2.Dt, log(g2.GDP/g1.GDP) as GDPGrowth, 
		log(g2.StockIndex/g1.StockIndex) as ExpRet
from g1 
join g2 on g1.rn=g2.rn and g1.Country=g2.Country
where g2.Dt<'2024-01-01' 
); 


select *
from OutSample
where Dt>'2022-12-01'

use Securities;
select *
from GlobalRecessions
where CountryCode='USA';









