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
cov <- fread(cov_file, h=T)
plist <- fread(phen_list, h=F)
clist <- fread(cov_list, h=F)

output<-NULL

for (i in 1:nrow(plist)) {
phen <- paste(plist[i])
merge <- merge(ph, cov, by = "IID")
  
ph2 <- subset(merge, select=c("IID", phen, "Sex", "Age",
                        "PC1", "PC2", "PC3", "PC4", "PC5",
                        "PC6", "PC7", "PC8", "PC9", "PC10",
                        "PC11", "PC12", "PC13", "PC14", "PC15",
                        "PC16", "PC17", "PC18", "PC19", "PC20"))
names(ph2)<-c("IID", "Outcome", "Sex", "Age",
                        "PC1", "PC2", "PC3", "PC4", "PC5",
                        "PC6", "PC7", "PC8", "PC9", "PC10",
                        "PC11", "PC12", "PC13", "PC14", "PC15",
                        "PC16", "PC17", "PC18", "PC19", "PC20")

mean <- mean(ph2$Outcome, na.rm=T)
sd <- sd(ph2$Outcome, na.rm=T)
median <- median(ph2$Outcome, na.rm=T)

q1 <- as.numeric(summary(ph2$Outcome)[2])
q3 <- as.numeric(summary(ph2$Outcome)[5])
min <- as.numeric(summary(ph2$Outcome)[1])
max <- as.numeric(summary(ph2$Outcome)[6])

miss <- is.na(ph2$Outcome)
N <- as.numeric(summary(miss)[2])

model1 <- lm(Outcome ~ Sex + Age + PC1 + PC2 + PC3 + PC4 + PC5
             + PC6 + PC7 + PC8 + PC9 + PC10
             + PC11 + PC12 + PC13 + PC14 + PC15
             + PC16 + PC17 + PC18 + PC19 + PC20, data = ph2)
sd_resid <- sd(resid(model1))
  
stats<-data.frame(phen, N, mean, sd, sd_resid, median, min, max, q1, q3)
output<-rbind(output,stats)
}


for (i in 1:nrow(clist)) {
phen <- paste(clist[i])
cov2 <- subset(cov, select = c("IID", phen))
names(cov2) <- c("IID", "Covariate")

mean <- mean(cov2$Covariate, na.rm = T)
sd <- sd(cov2$Covariate, na.rm = T)
median <- median(cov2$Covariate, na.rm = T)

q1 <- as.numeric(summary(cov2$Covariate)[2])
q3 <- as.numeric(summary(cov2$Covariate)[5])
min <- as.numeric(summary(cov2$Covariate)[1])
max <- as.numeric(summary(cov2$Covariate)[6])
  
miss <- is.na(cov2$Covariate)
N <- as.numeric(summary(miss)[2])

sd_resid <- NA
  
stats<-data.frame(phen, N, mean, sd, sd_resid, median, min, max, q1, q3)
output<-rbind(output,stats)
}

write.table(output, file=out_file, row=F, qu=F)
