#!/usr/bin/Rscript

# Read input
df <- read.table("sibling-covariates.txt", header=T, sep="\t")

# Remove missing
df2 <- df[complete.cases(df[ ,c("Age", "Sex")]),]

# Recode variables
df2$Sex <- df2$Sex-1

df2$Age <- 2019-df2$Age 

write.table(df2, "sibling-covariates-clean.txt", row.names=F, col.names=T, sep='\t', quote=F)
