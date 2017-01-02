setClass("Logit", slots= c(y="numeric", X = "matrix", ests = "numeric",
                           stand_errs = "numeric"))
setGeneric(name="init_data", def = function(object){
  standardGeneric("init_data")
})
setMethod(f="init_data", signature="Logit",
          definition= function(object){
            DATA <- read.csv("~/Google Drive/UCI/Year_1/Econometrics/Data_PS2a_S15.csv",
                             header=FALSE)
            object@y = DATA[,1]
            object@X = as.matrix(DATA[,2:4])
            return(object)
          })
setGeneric(name="LLLogit",
           def=function(object, betas){
             standardGeneric("LLLogit")
           }
           )
setMethod(f="LLLogit", signature="Logit",
          definition = function(object,betas){
            q = 2*object@y - 1 
            xTimesb = as.matrix(object@X) %*% betas
            prob = plogis(q * xTimesb)
            log_like = sum( log(prob) )
            return(-log_like)
          }
          )
setGeneric(name="optimize", def = function(object, guess){
  standardGeneric("optimize")
})
setMethod(f="optimize", signature = "Logit",
          definition = function(object, guess ){
            if(missing(guess)){
              guess = matrix(c(.01, .02, .3))
            }
            results <- optim(guess, LLLogit, object = object, hessian=T)
            object@ests <- as.numeric(results[[1]])
            hessian <- results[[6]]
            invHessian <- solve(hessian)
            object@stand_errs <- sqrt(diag(invHessian))
            return(object)
          })
setGeneric(name="DisplayEstimates", def = function(object){standardGeneric("DisplayEstimates")})
setMethod(f="DisplayEstimates", signature = "Logit", 
          definition = function(object){
            logit_results <- rbind(object@ests, object@stand_errs)
            colnames(logit_results) <- c("Constant", "Beta 1", "Beta 2")
            rownames(logit_results) <- c("Coef.s", "S.E.s")
            print(logit_results)
          })

lgt<- new("Logit")
lgt<-init_data(lgt)
lgt <- optimize(lgt)
DisplayEstimates(lgt)
