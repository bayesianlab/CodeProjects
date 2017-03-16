.open flend.db
.mode column
.headers on

select * from oneArranger limit 5;
.print 'only one arranger number of rows'
select count(*) from oneArranger;
.print 'null values'
select count(*) - count(BankAllocation) from oneArranger;
.print 'lead arranger gave less than 50'
select count(*) from oneArranger where BankAllocation < 50;
.print 'lead gave more or 50'
select count(*) from oneArranger where BankAllocation >= 50;

drop table if exists lessThan50;
create table lessThan50
as select *
from oneArranger 
where BankAllocation < 50;

drop table if exists moreThan50;
create table moreThan50
AS select *
from oneArranger 
where BankAllocation >= 50;
