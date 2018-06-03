setClass("BayesianLinearReg", slots=c(y="numeric", x="matrix", ests="numeric", 
                                      standard_errors="numeric"))
setGeneric("gibbSmpl", function(self){standardGeneric("gibbSmpl")})
setMethod(f="gibbSmpl", signature="BayesianLinearReg", definition=function(self){
  print("executed")
})

