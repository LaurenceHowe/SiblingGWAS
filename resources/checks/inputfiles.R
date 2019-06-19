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

message("Checking covariates: ", cov_file)

if(cov_file == "NULL") 
{
	msg <- paste0("No covariate file has been provided.")
	warninglist <- c(warninglist, msg)
	message("WARNING: ", msg)
	q()
}

message("Checking genotype fam file: ", genotype_ids)

if(genotype_ids == "NULL") 
{
	msg <- paste0("No PLINK .fam file has been provided.")
	warninglist <- c(warninglist, msg)
	message("WARNING: ", msg)
	q()
}

#Read in files

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

cohort_summary <- list()

if("Height" %in% names(ph))
{
	cohort_summary$Height_sample_size <- sum(!is.na(m$Height))
	cohort_summary$Height_n_male <- sum(m$Sex_factor == "M" & !is.na(m$Height))
	cohort_summary$Height_n_female <- sum(m$Sex_factor == "F" & !is.na(m$Height))
	cohort_summary$Height_mean_age <- mean(m$Age_numeric[!is.na(m$Height)], na.rm=TRUE)
	cohort_summary$mean_Height <- mean(m$Height,na.rm=T)
	cohort_summary$median_Height <- median(m$Height,na.rm=T)
	cohort_summary$sd_Height <- sd(m$Height,na.rm=T)
	cohort_summary$max_Height <- max(m$Height,na.rm=T)
	cohort_summary$min_Height <- min(m$Height,na.rm=T)
	
	cohort_summary$mean_Height_male <- mean(m$Height[m$Sex_factor=="M"], na.rm=T)
	cohort_summary$median_Height_male <- median(m$Height[m$Sex_factor=="M"], na.rm=T)
	cohort_summary$sd_Height_male <- sd(m$Height[m$Sex_factor=="M"], na.rm=T)
	cohort_summary$max_Height_male <- max(m$Height[m$Sex_factor=="M"], na.rm=T)
	cohort_summary$min_Height_male <- min(m$Height[m$Sex_factor=="M"], na.rm=T)
	
	cohort_summary$mean_Height_female <- mean(m$Height[m$Sex_factor=="F"], na.rm=T)
	cohort_summary$median_Height_female <- median(m$Height[m$Sex_factor=="F"], na.rm=T)
	cohort_summary$sd_Height_female <- sd(m$Height[m$Sex_factor=="F"], na.rm=T)
	cohort_summary$max_Height_female <- max(m$Height[m$Sex_factor=="F"], na.rm=T)
	cohort_summary$min_Height_female <- min(m$Height[m$Sex_factor=="F"], na.rm=T)
}

if("BMI" %in% names(ph))
{
	cohort_summary$BMI_sample_size <- sum(!is.na(m$BMI))
	cohort_summary$BMI_n_male <- sum(m$Sex_factor == "M" & !is.na(m$BMI))
	cohort_summary$BMI_n_female <- sum(m$Sex_factor == "F" & !is.na(m$BMI))
	cohort_summary$BMI_mean_age <- mean(m$Age_numeric[!is.na(m$BMI)], na.rm=TRUE)
	cohort_summary$mean_BMI <- mean(m$BMI,na.rm=T)
	cohort_summary$median_BMI <- median(m$BMI,na.rm=T)
	cohort_summary$sd_BMI <- sd(m$BMI,na.rm=T)
	cohort_summary$max_BMI <- max(m$BMI,na.rm=T)
	cohort_summary$min_BMI <- min(m$BMI,na.rm=T)

	cohort_summary$mean_BMI_male <- mean(m$BMI[m$Sex_factor=="M"], na.rm=T)
	cohort_summary$median_BMI_male <- median(m$BMI[m$Sex_factor=="M"], na.rm=T)
	cohort_summary$sd_BMI_male <- sd(m$BMI[m$Sex_factor=="M"], na.rm=T)
	cohort_summary$max_BMI_male <- max(m$BMI[m$Sex_factor=="M"], na.rm=T)
	cohort_summary$min_BMI_male <- min(m$BMI[m$Sex_factor=="M"], na.rm=T)
	
	cohort_summary$mean_BMI_female <- mean(m$BMI[m$Sex_factor=="F"], na.rm=T)
	cohort_summary$median_BMI_female <- median(m$BMI[m$Sex_factor=="F"], na.rm=T)
	cohort_summary$sd_BMI_female <- sd(m$BMI[m$Sex_factor=="F"], na.rm=T)
	cohort_summary$max_BMI_female <- max(m$BMI[m$Sex_factor=="F"], na.rm=T)
	cohort_summary$min_BMI_female <- min(m$BMI[m$Sex_factor=="F"], na.rm=T)
}

save(cohort_summary, file=cohort_descriptives_file)
message("\n\nCompleted checks\n")

message("Summary of data:")
for(i in 1:length(cohort_summary))
{
	a <- cohort_summary[[i]]
	if(is.numeric(a)) a <- round(a, 2)
	message(names(cohort_summary)[i], ": ", paste(a, collapse=", "))
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
