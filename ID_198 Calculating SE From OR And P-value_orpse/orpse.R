args = commandArgs(trailingOnly=TRUE)
argsCount = 4

if (length(args)!=argsCount) {
  stop("betase.R libPath OR P outputFileName")
}
.libPaths(args[1])

OR <- as.numeric(args[2])
if (is.na(OR)) {
  OR <- "4.48"
}

P<- as.numeric(args[3])
if (is.na(P)) {
 P <- "0.03"
}

outputFileName <- args[4]
if (is.na(outputFileName)) {
  outputFileName <- "result"
}


transform<- function(or,p) {
       se=as.data.frame(abs(log(or)/qnorm(p/2)))
       print(se)
   }                  
                   
     aa = transform(OR,P)             
 colnames(aa) <- "se"    

write.csv(aa,paste(outputFileName,".csv",sep=""))
