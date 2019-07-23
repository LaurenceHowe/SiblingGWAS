errorlist <- list()
warninglist <- list()

library(data.table)
suppressMessages(library(matrixStats))

args <- (commandArgs(TRUE));
phenotype_file <- as.character(args[1]);
cov_file <- as.character(args[2]);
phen_list <- as.character(args[3])
cov_list <- as.character(args[4])
out_file <- as.character(args[5])

ph <- fread(phenotype_file, h=T)
cov <-fread(cov_file, h=T)
plist<-fread(phen_list, h=F)
clist<-fread(cov_list, h=F)

temp<-paste(outcome)
phen2<-subset(phen, select=c("IID", temp))

for (i in 1:nrow(plist)) {
phen<-paste(plist[i])
ph2<-subset(ph, select=c("IID", phen))
names(ph2)<-c("IID", "Outcome")

mean<-mean(ph2$Outcome, na.rm=T)
sd<-sd(ph2$Outcome, na.rm=T)
median<-median(ph2$Outcome, na.rm=T)

total<-nrow(ph2)
miss<-is.na(ph2$Outcome)
miss2<-as.numeric(summary(miss)[3])
missing<-miss2/total

stats<-data.frame(phen,mean,sd,median,total,missing)
output<-rbind(output,stats)
}
