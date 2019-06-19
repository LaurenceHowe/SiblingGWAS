errorlist <- list()
warninglist <- list()

library(data.table)
suppressMessages(library(matrixStats))

args <- (commandArgs(TRUE));
phenotype_file <- as.character(args[1]);
genotype_ids <- as.character(args[2])

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
g_ids <- fread(genotype_ids.fam)

if(names(ph)[1] !="IID")
	{
	msg <- paste0("First column in phenotype file should be the sample identified with the name IID")
	errorlist <-c(errorlist, msg)
	warning("ERROR: ", msg)
	}

commonids_pg<-Reduce(intersect, list(ph$IID, g_ids$V2))
message(length(commonids_pg), " in common between phenotype and genotype data")

if(length(commonids_mpc)<50)
	{
	msg <-paste0("fewer than 50 subjects with phenotype and genotype data")
	warninglist<-c(warninglist, msg)
	warning("Warning: ", msg)
	}

ph<-subset(ph, IID%in%commonids_pg)
g_ids<-subset(g_ids, V2%in%commonids_pg)

if(p2<2)
	{
	msg <-paste0("No phenotypes present.")
	errorlist <-c(errorlist,msg)
	warning("ERROR: ", msg)
	}

nom <- names(ph)[-1]names(ph)[-1] %in% c("BMI", "Height")]
if(length(nom)<1)
	{
	msg <-paste0("Neither Height nor BMI are present in the phenotype file. Please check that the columns are labelled correctly")
	errorlist <-c(errorlist,msg)
	warning("ERROR: ", msg)
	}


	

