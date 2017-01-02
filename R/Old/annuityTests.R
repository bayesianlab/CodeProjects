# Annuity Tests

source('/Users/dillonflannery-valadez/R projects/annuity.R')

annuityTests <- function(){
  epsilon <- .001
  # 5%  7 yrs, 8% 19 yrs, 10% 35 yrs
  answers <- c(5.78637, 9.6036, 9.64416)
  returns <- c(annuity(1, 5, 7), annuity(1, 8, 19), annuity(1, 10, 35))
  for(i in 1:length(answers)){
    if(abs(answers[i] - returns[i]) < epsilon){
      print(TRUE)}else{
        print(FALSE)
      }
    
  }
  return(NULL)
}

annuityTests()