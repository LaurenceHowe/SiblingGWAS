errorlist <- list()
warninglist <- list()

library(data.table)
suppressMessages(library(matrixStats))

args <- (commandArgs(TRUE));
cov_file <- as.character(args[1]);
fam_file <- as.character(args[2]);
phen_file <-as.character(args[3]);
cov_list_file <- as.character(args[4])

message("Checking covariates: ", cov_file)

if(cov_file == "NULL") 
{
	msg <- paste0("No covariate file has been provided.")
	warninglist <- c(warninglist, msg)
	message("WARNING: ", msg)
	q()
}

cov<-fread(cov_file, h=T)
cov1<-dim(cov)[1]
cov2<-dim(cov)[2]

fam<-read.table(fam_file, h=F, stringsAsFactors=F)

phen<-fread(phen_file, h=T)

#Check IDs

if(names(cov)[1] !="FID")
	{
	msg <- paste0("First column in covariate file should be the FID")
	errorlist <-c(errorlist, msg)
	warning("ERROR: ", msg)
	}

if(names(cov)[2] !="IID")
	{
	msg <- paste0("Second column in covariate file should be the sample identified with the name IID")
	errorlist <-c(errorlist, msg)
	warning("ERROR: ", msg)
	}

commonids_cpg <- Reduce(intersect, list(cov$IID, phen$IID, fam[,2]))
message("Number of samples with covariate, genetic and phenotype data: ", length(commonids_cpg))



if(length(commonids_cpg) < 50)

{
	msg <- paste0("must have at least 50 individuals with covariate, genetic and phenotype data.")
	errorlist <- c(errorlist, msg)
	warning("ERROR: ", msg)
}

#Check Sex

sex <- names(cov)[-1][names(cov)[-1] %in% c("Sex")]
if(length(sex)<1)
	{
	msg <-paste0("Sex is not present in the covariate file. Please check that the columns are labelled correctly")
	errorlist <-c(errorlist,msg)
	warning("ERROR: ", msg)
	}
  
if(any(is.na(cov$Sex)))
  {
  msg<-paste0("Missing values for Sex. Please make sure all individuals have data for this covariate.")
  errorlist <-c(errorlist, msg)
  warning("ERROR: ", msg)
  }

index<-cov$Sex %in% c("1", "0")
if(any(!index))
  {
  msg<-paste0("There are some values in the Sex column that are neither 0 (F) nor 1 (M). Please categorise Males as 1 and Females as 0")
  errorlist<-c(errorlist, msg)
  warning("ERROR: ", msg)
  }
  
#Check Age

age <- names(cov)[-1][names(cov)[-1] %in% c("Age")]
if(length(age)<1)
	{
	msg <-paste0("Age is not present in the covariate file. Please check that the columns are labelled correctly")
	errorlist <-c(errorlist,msg)
	warning("ERROR: ", msg)
	}
  
  if(any(is.na(cov$Age)))
  {
  msg<-paste0("Missing values for age. Please make sure all individuals have data for this covariate.")
  errorlist <-c(errorlist, msg)
  warning("ERROR: ", msg)
  }
  
  if(any(cov$Age<0))
  {
   msg<-paste0("Negative values in the age column.")
  errorlist <-c(errorlist, msg)
  warning("ERROR: ", msg)
  }
  
  if(mean(cov$Age, na.rm=T)>100)
  {
   msg<-paste0("Average age is above 100, please make sure age is provided in years.")
  errorlist <-c(errorlist, msg)
  warning("ERROR: ", msg)
  }
  
#Check principal components
pccheck <- grep("PC", names(cov))
if(length(pccheck)<20)
	{
	msg <-paste0("The first 20 principal components are not present in the covariate file. Please check that the columns are labelled correctly")
	errorlist <-c(errorlist,msg)
	warning("ERROR: ", msg)
	}

  cov <- subset(cov, IID %in% commonids_cpg)

write.table(names(cov)[-2:-1], file=cov_list_file, row=F, col=F, qu=F)

message("\n\nCompleted checks\n")

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
