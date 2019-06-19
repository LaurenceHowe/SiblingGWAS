errorlist <- list()
warninglist <- list()

library(data.table)
suppressMessages(library(matrixStats))

args <- (commandArgs(TRUE));
phenotype_file <- as.character(args[1]);
cov_file <- as.character(args[2]);
genotype_ids <- as.character(args[3])

message("Checking phenotypes: ", phenotype_file)

if(phenotype_file == "NULL") 
{
	msg <- paste0("No phenotype file has been provided.")
	warninglist <- c(warninglist, msg)
	message("WARNING: ", msg)
	q()
}

ph <- fread(phenotype_file)
p1 <- dim(ph)[1]
p2 <- dim(ph)[2]
cov <-fread(cov_file)
g_ids <- fread(genotype_ids.fam)

#Check phenotype file

if(names(ph)[1] !="IID")
	{
	msg <- paste0("First column in phenotype file should be the sample identified with the name IID")
	errorlist <-c(errorlist, msg)
	warning("ERROR: ", msg)
	}

nom <- names(ph)[-1]names(ph)[-1] %in% c("BMI", "Height")]
if(length(nom)<1)
	{
	msg <-paste0("Neither Height nor BMI are present in the phenotype file. Please check that the columns are labelled correctly")
	errorlist <-c(errorlist,msg)
	warning("ERROR: ", msg)
	}

#Check covariate file

if(names(cov)[1] !="IID")
	{
	msg <- paste0("First column in covariate file should be the sample identified with the name IID")
	errorlist <-c(errorlist, msg)
	warning("ERROR: ", msg)
	}

sex <- names(cov)[-1]names(cov)[-1] %in% c("Sex")]
if(length(sex)<1)
	{
	msg <-paste0("Sex is not present in the covariate file. Please check that the columns are labelled correctly")
	errorlist <-c(errorlist,msg)
	warning("ERROR: ", msg)
	}

age <- names(cov)[-1]names(cov)[-1] %in% c("Age")]
if(length(age)<1)
	{
	msg <-paste0("Age is not present in the covariate file. Please check that the columns are labelled correctly")
	errorlist <-c(errorlist,msg)
	warning("ERROR: ", msg)
	}

#Check genotype file

if(names(g_ids)[2] !="V2")
	{
	msg <- paste0("The .fam file should not have a header.")
	errorlist <-c(errorlist, msg)
	warning("ERROR: ", msg)
	}

#Intersection of files
commonids_pg<-Reduce(intersect, list(ph$IID, cov$IID, g_ids$V2))
message(length(commonids_pg), " in common between phenotype, covariate and genotype data")

if(length(commonids_mpc)<50)
	{
	msg <-paste0("fewer than 50 subjects with phenotype, covariate and genotype data")
	warninglist<-c(warninglist, msg)
	warning("Warning: ", msg)
	}

ph<-subset(ph, IID%in%commonids_pg)
g_ids<-subset(g_ids, V2%in%commonids_pg)
	
#Phenotype checks

if("Height" %in% nom)
{
	message("Checking Height")
	m1 <- mean(ph$Height,na.rm=T)
	age.mean<-mean(ph$Age,na.rm=T)
	if((m1<1.0|m1>2.5)&age.mean>10)
	{
	msg <- paste0("please convert Height units to metres")
	errorlist <- c(errorlist, msg)
	warning("ERROR: ", msg)
	}
}

if("Height" %in% nom)
{
	message("Checking Height")
	m1 <- mean(ph$Height,na.rm=T)
	age.mean<-mean(ph$Age,na.rm=T)
	if((m1<0.2|m1>2.5)&age.mean<10)
	{
	msg <- paste0("please convert Height units to metres")
	errorlist <- c(errorlist, msg)
	warning("ERROR: ", msg)
	}
}

if("BMI" %in% nom)
{
	message("Checking BMI")
	m1<-mean(ph$BMI,na.rm=T)
	age.mean<-mean(covar$Age,na.rm=T)
	if((m1<10|m1>35)&age.mean>2)
	{
	msg <- paste0("please convert BMI units to kg/m2")
	errorlist <- c(errorlist, msg)
	warning("ERROR: ", msg)
	}
}

write.table(names(ph)[-1], file=gwas_phenotype_list_file, row=F, col=F, qu=F)




	

