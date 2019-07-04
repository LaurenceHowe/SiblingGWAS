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
bim <- as.data.frame(fread(bim_file, h=F))

message("Number of SNPs: ", nrow(bim))

# test chr coding
chrno <- data.frame(table(bim[,1]))
names(chrno)<-c("CHR", "Freq")
w <- which(!chrno$CHR %in% as.character(c(1:23)))

print(chrno)

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

#message("Checking strand against control SNPs")
#for (i in 1:22)
#{
#	chr <- bim2[which(bim2[,1] %in% i),]
#	controlsnps.chr <- na.omit(controlsnps[which(controlsnps$V2 %in% i), ])
#	controlsnps.chr$V6<-as.character(controlsnps.chr$V6)
#	w<-which(controlsnps.chr$V5=="-"&controlsnps.chr$V6=="AG")
#	if(length(w)>0){controlsnps.chr$V6[w]<-"CT"}
#    w<-which(controlsnps.chr$V5=="-"&controlsnps.chr$V6=="AC")
#	if(length(w)>0){controlsnps.chr$V6[w]<-"GT"}
#
#	m<-match(controlsnps.chr$V3,chr$V4)
#	chr<-chr[na.omit(m),]
#	m<-match(chr$V4,controlsnps.chr$V3)
#	controlsnps.chr<-controlsnps.chr[m,]
#    strand.check<-sum(controlsnps.chr$V6==chr$alleles,na.rm=T)/nrow(controlsnps.chr)
#    message("Chr ", i, " proportion in agreement: ", strand.check)	
#	if(strand.check<0.75)
#	{
#		msg <- paste0("please check strand for chromosome ",i," as more than 25% of your SNPs have strand issues")
#		errorlist <- c(errorlist, msg)
#		warning("ERROR: ", msg)
#	}
#}

message("Checking for duplicate SNPs")
if(any(duplicated(bim[,2])))
{
	msg <- "duplicate SNPs in bim file"
	errorlist <- c(errorlist, msg)
	warning("ERROR: ", msg)
}

message("Checking imputation quality scores: ", quality_file)
qual <- as.data.frame(fread(quality_file,header=T))

if(ncol(qual) != 3)
{
	msg <- paste0("Expecting 3 columns in the imputation quality file: SNP ID, MAF and quality score.")
	errorlist <- c(errorlist, msg)
	warning("ERROR: ", msg)
}

if(any(qual[,2] < 0) | any(qual[,2] > 1))
{
	msg <- paste0("Second column of quality scores file should be MAF. Some of the provided values fall outside the range of 0-1")
	errorlist <- c(errorlist, msg)
	warning("ERROR: ", msg)
}

if(any(qual[,3] > 1.1))
{
	msg <- paste0("Third column of quality scores file should be the info score. Some of the provided values are above 1.")
	msg <- c(errorlist, msg)
	warning("ERROR: ", msg)
}

prop <- sum(bim[,2] %in% qual[,1]) / nrow(bim)
if(prop < 0.95)
{
	msg <- paste0("Less then 95% of SNPs in the genetic data have info scores provided.")
	errorlist <- c(errorlist, msg)
	warning("ERROR: ", msg)
}

message(round(prop*100, 2), "% of the SNPs in the data have matching info scores.")
qual <- qual[qual[,1] %in% bim[,2], ]
message("Retaining ", nrow(qual), " quality scores.")

names(qual) <- c("V1", "V2", "V3")
index <- qual$V2 > 0.5
qual$V2[index] <- 1 - qual$V2[index]

prop <- sum(qual[,2] < 0.01) / nrow(qual)
if(prop > 0.01)
{
	msg <- paste0("More than 1% of the retained quality scores have a MAF < 0.01. Please filter on MAF < 0.01")
	errorlist <- c(errorlist, msg)
	warning("ERROR: ", msg)
}

prop <- sum(qual[,3] < 0.3) / nrow(qual)
if(prop > 0.01)
{
	msg <- paste0("More than 1% of the retained quality scores have a quality score < 0.3. Please filter the data.")
	errorlist <- c(errorlist, msg)
	warning("ERROR: ", msg)
}

message("Checking fam file: ", fam_file)

fam <- read.table(fam_file,header=F,stringsAsFactors=F)

if(any(duplicated(fam[,2])))
{
	msg <- paste0("Individual identifier is not unique. Please fix this before going on.")
	errorlist <- c(errorlist, msg)
	warning("ERROR: ", msg)
}

if(length(warninglist) > 0)
{
	message("\n\nPlease take note of the following warnings, and fix and re-run the data check if you see fit:")
	null <- sapply(warninglist, function(x)
	{
		message("- ", x)
	})
}

if(length(errorlist) > 0)
{
	message("\n\nThe following errors were encountered, and must be addressed before continuing:")
	null <- sapply(errorlist, function(x)
	{
		message("- ", x)
	})
	q(status=1)
}
message("\n\n")
