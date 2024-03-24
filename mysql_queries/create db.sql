use Securities;
create  table stock_prices
(
  id int NOT NULL AUTO_INCREMENT primary key,
  grp_id varchar(30), 
  freq varchar(10), 
  ticker varchar(30) NOT NULL,
  dt datetime NOT NULL,
  opening decimal(19,4) NULL,
  high decimal(19,4) NULL,
  low decimal(19,4) NULL,
  closing decimal(19,4) NULL,
  adj_close decimal(19,4) NULL,
  volume bigint NULL
)Engine=InnoDB AUTO_INCREMENT=1 Default charset=utf8mb4;

-- drop table snp500; 
create table snp500
(
    symbol varchar(25) not null primary key,
    sec_name varchar(25) not null, 
    sector varchar(35) not null, 
    sub_industry varchar(35)
)Engine=InnoDB AUTO_INCREMENT=1 Default charset=utf8mb4;

-- drop table tentwo_spr
create table tentwo_sprd
(
	dt date primary key not null,
    sprd decimal(8,5)
)Engine=InnoDB AUTO_INCREMENT=1 Default charset=utf8mb4;

create table nber_recessions
(
	dt date primary key not null,
    recession_indicator int
)Engine=InnoDB AUTO_INCREMENT=1 Default charset=utf8mb4;

create table truck_ton
(
	dt date primary key not null,
    tons decimal(9,3)
)Engine=InnoDB AUTO_INCREMENT=1 Default charset=utf8mb4;

-- drop table fed_funds
create table fed_funds
(
	dt date primary key not null,
    rate decimal(10,5)
)Engine=InnoDB AUTO_INCREMENT=1 Default charset=utf8mb4;

-- drop table spy
create table spy
(
  id int NOT NULL AUTO_INCREMENT primary key,
  grp_id varchar(30), 
  freq varchar(10), 
  ticker varchar(30) NOT NULL,
  dt datetime NOT NULL,
  opening decimal(19,4) NULL,
  high decimal(19,4) NULL,
  low decimal(19,4) NULL,
  closing decimal(19,4) NULL,
  adj_close decimal(19,4) NULL,
  volume bigint NULL	
)Engine=InnoDB AUTO_INCREMENT=1 Default charset=utf8mb4;