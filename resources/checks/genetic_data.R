errorlist<-list()
warninglist<-list()

library(data.table)
suppressMessages(library(matrixStats))

args <- (commandArgs(TRUE));
bim_file <- as.character(args[1])
fam_file <- as.character(args[2])
quality_file <- as.character(args[3])
controlsnps_file <- as.character(args[4])

message("Checking bim file: ", bim_file)
controlsnps <- read.table(controlsnps_file, header=F, stringsAsFactors=F)
bim <- fread(bim_file, h=F)

message("Number of SNPs: ", nrow(bim))

# test chr coding
chrno <- table(bim[,1])
w <- which(! names(chrno) %in% as.character(c(1:23)))

print(data.frame(chrno))

if(length(w) > 0)
{
	msg <- paste0("There are some chromosomes other than 1-23, they will be removed")
	warninglist <- c(warninglist, msg)
	message("Warning: ", msg)
}

w <- which(names(chrno) %in% c(1:23))
if(length(w)<22)
{
	msg <- "Please change chromosome coding to 1-23, please dont use chr1, chr2, X etc."
	errorlist <- c(errorlist, msg)
	warning("ERROR: ", msg)
}

w <- which(names(chrno) %in% c("X","chrX"))
if(length(w)>0)
{
	msg <- "Please change chromosome coding to 23, please dont use chrX or X etc."
	errorlist <- c(errorlist, msg)
	warning("ERROR: ", msg)
}

message("Checking strand")

bim2<-data.frame(bim,alleles=paste(bim[,5],bim[,6],sep=""))
bim2$alleles<-as.character(bim2$alleles)
w<-which(bim2$alleles=="GA")
bim2$alleles[w]<-"AG"
w<-which(bim2$alleles=="CA")
bim2$alleles[w]<-"AC"
w<-which(bim2$alleles=="TC")
bim2$alleles[w]<-"CT"
w<-which(bim2$alleles=="TG")
bim2$alleles[w]<-"GT"

message("Checking strand against control SNPs")
for (i in 1:22)
{
	chr <- bim2[which(bim2[,1] %in% i),]
	controlsnps.chr <- na.omit(controlsnps[which(controlsnps$V2 %in% i), ])
	controlsnps.chr$V6<-as.character(controlsnps.chr$V6)
	w<-which(controlsnps.chr$V5=="-"&controlsnps.chr$V6=="AG")
	if(length(w)>0){controlsnps.chr$V6[w]<-"CT"}
    w<-which(controlsnps.chr$V5=="-"&controlsnps.chr$V6=="AC")
	if(length(w)>0){controlsnps.chr$V6[w]<-"GT"}

	m<-match(controlsnps.chr$V3,chr$V4)
	chr<-chr[na.omit(m),]
	m<-match(chr$V4,controlsnps.chr$V3)
	controlsnps.chr<-controlsnps.chr[m,]
    strand.check<-sum(controlsnps.chr$V6==chr$alleles,na.rm=T)/nrow(controlsnps.chr)
    message("Chr ", i, " proportion in agreement: ", strand.check)	
	if(strand.check<0.75)
	{
		msg <- paste0("please check strand for chromosome ",i," as more than 25% of your SNPs have strand issues")
		errorlist <- c(errorlist, msg)
		warning("ERROR: ", msg)
	}
}

message("Checking for duplicate SNPs")
if(any(duplicated(bim[,2])))
{
	msg <- "duplicate SNPs in bim file"
	errorlist <- c(errorlist, msg)
	warning("ERROR: ", msg)
}
