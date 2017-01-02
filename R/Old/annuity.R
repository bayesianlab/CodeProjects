# Find the present value of an annuity
isChar <- function(input){
  if(typeof(input) == 'character'){
    return(T)
  }else{
    return(F)
  }
}

annuityFac <- function( int, time){
  int <- int/100
  Num <- 1-(1/(1+int)^time)
  annFac <- Num/int
  return(annFac)
}

annuity <- function(pv, cash, int, time){
  # Returns the present value of annuity if pv is set to a unknown 
  # character like 'x'. If cash is set to an unknown variable like
  # 'x' and pv is known it returns the cash flows per period. 
  # If both are unknown it returns 'error'. 
  epsilon = 1
  annFac = annuityFac(int, time)
  if(isChar(pv) == T & isChar(cash) == F){
    cat("The present value of those cash flows are:", "\n")
    return(annFac*cash)
  }
  if(isChar(pv) == F & isChar(cash) == T){
    cat("The stream of cash flows will be:", "\n")
    return(pv/annFac)
  }
  if(isChar(pv) == F & isChar(cash) == F){
    if(abs(pv - annFac*cash) < epsilon){
      cat("The annuity factor was:", "\n")
      print(annFac)
      cat("The error was:", "\n")
      print(pv - annFac*cash)
      return(T)
    }else{
      cat("Error. Present Value not equal to discounted cash flows.", "\n")
      print(annFac*cash)
      return(F)
    }
  }
  else{
    return(Error)
  }
}




