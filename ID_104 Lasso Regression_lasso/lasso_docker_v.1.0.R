
args = commandArgs(trailingOnly=TRUE)
argsCount = 8


if (length(args)!=argsCount) {
  stop("lasso_docker_v.1.0.R libPath inputFile1 inputFile2 family_model is_alpha outputFileName1 outputFileName2 outputFileName3")
}
.libPaths(args[1])
inputFile1 <- args[2]
inputFile2 <- args[3]

family_model <- args[4]
if (is.na(family_model)) {
  family_model <- "cox"
}
is_alpha <-as.numeric(args[5])
if (is.na(is_alpha)) {
  is_alpha <- "1"
}
outputFileName1 <- args[6]
if (is.na(outputFileName1)) {
  outputFileName1 <- "model_lasso"
}
outputFileName2 <- args[7]
if (is.na(outputFileName2)) {
  outputFileName2 <- "Cross_validation_for_glmnet"
}
outputFileName3 <- args[8]
if (is.na(outputFileName3)) {
  outputFileName3 <- "result"
}

library(glmnet)
library(myplot)
data<-read.delim(inputFile1,header=T,sep="\t",check.names=F,row.names=1)

five_model <- c("binomial","gaussian","mgaussian","poisson","multinomial")
cox_model <- c("cox")

if(family_model %in% five_model){

x<-as.matrix(data)
data_outcome_variable<-read.delim(inputFile2,header=T,sep="\t",check.names=F,row.names=1)
y=as.matrix(data_outcome_variable)
#colnames(y)=c("status","time")
#y <-Surv(as.double(nData.test.cox1$OS.time,2),as.double(nData.test.cox1$OS))

model_lasso <- glmnet(x = x, y = y, family = family_model, alpha = is_alpha)


p1 = myplot({plot(model_lasso, xvar = "lambda",label = T)})


cv_fit <- cv.glmnet(x, y, family=family_model,nfolds=10) 
p2 = myplot({plot(cv_fit)})



coef.min = coef(cv_fit, s = cv_fit$lambda.min)

coef.min1 <- coef.min[which(coef.min !=0),]
coef.min2 <- matrix(coef.min1,length(coef.min1),1)
colnames(coef.min2)=c("coef.min1")
row.names(coef.min2)=names(coef.min1)
coef.min2=cbind(id=row.names(coef.min2),coef.min2)
#write.table(coef.min2,file="coef.min.txt",sep="\t",quote=F,row.names = F)
#write.table(coef.min2,file=paste(outputFileName3,"coef_min.txt",sep="_"),sep="\t",quote=F,row.names = F)


}else if(family_model %in% cox_model){

x<-as.matrix(data)
data_outcome_variable<-read.delim(inputFile2,header=T,sep="\t",check.names=F,row.names=1)
y=as.matrix(data_outcome_variable)
colnames(y)=c("status","time")
model_lasso <- glmnet(x = x, y = y, family = "cox", alpha = is_alpha)
p1 = myplot({plot(model_lasso, xvar = "lambda",label = T)})

cv_fit <- cv.glmnet(x, y, family="cox",nfolds=10) 
p2 = myplot({plot(cv_fit)})

coef.min = coef(cv_fit, s = cv_fit$lambda.min)

coef.min1 <- coef.min[which(coef.min !=0),]
coef.min2 <- matrix(coef.min1,length(coef.min1),1)
colnames(coef.min2)=c("coef.min1")
row.names(coef.min2)=names(coef.min1)
coef.min2=cbind(id=row.names(coef.min2),coef.min2)
##write.table(coef.min2,file="coef.min.txt",sep="\t",quote=F,row.names = F)
#coef_min = coef(cv_fit, s = cv_fit$lambda.min)


}

plotsave(p1,file=paste(outputFileName1,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)
plotsave(p2,file=paste(outputFileName2,"svg",sep="."),unit="cm",width=15,height=15,dpi=600)
write.table(coef.min2,file=paste(outputFileName3,"coef_min.txt",sep="_"),sep="\t",quote=F,row.names = F)

