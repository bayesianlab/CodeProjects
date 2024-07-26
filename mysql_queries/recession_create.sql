use Securities;
-- drop table dbo.recessions;
create table recessions
(
CountryCode varchar(128) not null,
Yr int not null,
Mon int not null, 
Country varchar(128) not null ,
IndustrialProd double, 
Investment double, 
Employment double, 
StockIndex double ,
GDP double 
)Engine=InnoDB AUTO_INCREMENT=1 Default charset=utf8mb4;
