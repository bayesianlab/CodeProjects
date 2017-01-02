library("vars")
cpi <- read.csv("~/Google Drive/MATLAB/Macro Swanson/cpi.csv")
output <- read.csv("~/Google Drive/MATLAB/Macro Swanson/INDPRO.csv")
t_bonds <- read.csv("~/Google Drive/MATLAB/Macro Swanson/t_bonds.csv")
rows_cols_output <- dim(output)
row_cols_cpi <- dim(cpi)
row_cols_t_bonds <- dim(t_bonds)

start_date <- 470
rc_output<- dim(output)
output <- output[start_date:rc_output[1], 2]
start_date <- 14
rc_cpi <- dim(cpi)
cpi <- cpi[start_date:rc_cpi[1], 2]
rc_t_bonds <- dim(t_bonds)
start_date <- 59
t_bonds <- t_bonds[start_date:rc_t_bonds[1],2]
dat_mat <- matrix(c(cpi, output, t_bonds), ncol=3)
v <- VAR(dat_mat, 2, type="const")
Acoef(v)
