# Present Value Function
pval <- function(cash, int, periods){
  ans<- cash/ ((1 + (int/100))^periods)
  return(ans)
}

# Future Value
fval <- function(cash, int, periods){
  ans <- cash* (1 + int/100)^periods
  return(ans)
}