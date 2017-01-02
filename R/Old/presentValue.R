presentValue <- function(cash, interestRate, time)
{
  interestRate <- interestRate/100
  Denominator <- (1 + interestRate)^time
  Answer <- cash/Denominator
  return(Answer)
}

presentValue(10, 30, 2)