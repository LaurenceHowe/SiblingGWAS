require(data.table)
require(sandwich)
require(lmtest)

# import argument
arguments <- commandArgs(trailingOnly = T)
rawfile <- arguments[1]
bimfile <- arguments[2]
phenfile <- arguments[3]
covfile <- arguments[4]
outfile <- arguments[5]
outcome <- arguments[6]
#---------------------------------------------------------------------------------------------#
# Begin GWAS code:
#---------------------------------------------------------------------------------------------#
# Track time:
time_start <- Sys.time()
paste0("Running GWAS for: ", outfile, " | Started: ")
time_start

paste0("Loading genetic data")
raw <- fread(rawfile, sep=" ")
bim <- fread(bimfile)

paste0("Loading phenotype data")
phen <- fread(phenfile)
temp<-paste(outcome)
phen2<-subset(phen, select=c("FID", "IID", temp))
names(phen2)<-c("FID", "IID", "Outcome")

paste0("Loading covariate data")
cov <- fread(covfile)

phencov<-merge(phen2,cov,by=c("FID", "IID"))
ped<-merge(raw,phencov, by=c("FID", "IID"))

# Create a new data.frame which will be filled with all necessary output information
output <- data.frame(CHR=bim$V1, SNP=bim$V2, BP=bim$V4, A1=bim$V5, A2=bim$V6, N_REG=NA,
                     BETA_MODEL1_0=NA, BETA_MODEL2_0=NA, BETA_TOTAL=NA, BETA_BF=NA, BETA_WF=NA,
                     SE_BETA_MODEL1_0=NA, SE_BETA_MODEL2_0=NA, SE_BETA_TOTAL=NA, SE_BETA_BF=NA, SE_BETA_WF=NA,
                     P_BETA_MODEL1_0=NA, P_BETA_MODEL2_0=NA, P_BETA_TOTAL=NA, P_BETA_BF=NA, P_BETA_WF=NA,
                     VCV_MODEL1_0=NA, VCV_MODEL1_0_TOTAL=NA, VCV_MODEL1_TOTAL=NA, 
                     VCV_MODEL2_0=NA, VCV_MODEL2_0_BF=NA, VCV_MODEL2_0_WF=NA, VCV_MODEL2_BF=NA, VCV_MODEL2_BF_WF=NA, VCV_MODEL2_WF=NA)

#---------------------------------------------------------------------------------------------#
# Loop over all SNPs in the partition
#---------------------------------------------------------------------------------------------#
paste0("Looping...")
ptm <- proc.time()

# loop over all SNPs
SNPs<- grep("SNP", colnames(ped), value = T)
INDELs <- grep("INDEL", colnames(ped), value=T)
Variants<-c(SNPs, INDELs)

for (i in 1:length(Variants)) {
    # Calculate the Callrate: for how many sibs the SNP is available
    snp_ind <- i+6 


    # Make a matrix with: [FID PHENOTYPE] [individ - family mean ] [family mean]
    ped2 <- data.table(FID=ped$FID, PHENOTYPE=ped$Outcome, GENOTYPE=as.numeric(unlist(ped[,snp_ind, with=F])), FAM_MEAN=ave(as.numeric(unlist(ped[,snp_ind, with=F])), ped$FID, FUN=mean), AGE=ped$Age, SEX=ped$Sex,
                       PC1=ped$PC1, PC2=ped$PC2, PC3=ped$PC3, PC4=ped$PC4, PC5=ped$PC5, PC6=ped$PC6, PC7=ped$PC7, PC8=ped$PC8, PC9=ped$PC9, PC10=ped$PC10,
                       PC11=ped$PC11, PC12=ped$PC12, PC13=ped$PC13, PC14=ped$PC14, PC15=ped$PC15, PC16=ped$PC16, PC17=ped$PC17, PC18=ped$PC18, PC19=ped$PC19, PC20=ped$PC20)
    
    #Centre genotype around family mean
    ped3 <- na.omit(ped2[,CENTREDGENOTYPE:=GENOTYPE-FAM_MEAN])
    
	# Extract total effect
	# Try and catch errors with regression

	skip_variant <- FALSE
	tryCatch(model1 <- lm(formula = PHENOTYPE ~ GENOTYPE + AGE + SEX +PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+PC11+PC12+PC13+PC14+PC15+PC16+PC17+PC18+PC19+PC20, data=ped3),
		 error = function(e){
			 print(e)
		         skip_variant <<- TRUE}
		)
	
if(skip_variant) { next } 
    
    #Save Beta information
    output$BETA_MODEL1_0[i] <- model1$coefficients[1]
    output$BETA_TOTAL[i] <- model1$coefficients[2]
    
    # Save the variance covariance matrix to cluster SEs by family
	# Try and catch errors with generating variance covariance matrix

	tryCatch(vcv_matrix <- vcovCL(model1, cluster=ped3$FID),
		 error = function (e){
			 print(e)
			 skip_variant <<-TRUE}
		 )
if(skip_variant) { next } 
	
    if(  is.na(output$BETA_MODEL1_0[i]) | is.na(output$BETA_TOTAL[i])) {
        output$VCV_MODEL1_0[i] <-NA
        output$VCV_MODEL1_0_TOTAL[i] <-NA
        output$VCV_MODEL1_TOTAL[i] <-NA
    } else {
        output$VCV_MODEL1_0[i] <- vcv_matrix[1,1]
        output$VCV_MODEL1_0_TOTAL[i] <- vcv_matrix[1,2]
        output$VCV_MODEL1_TOTAL[i] <- vcv_matrix[2,2]
 
    }
	
	#Derive the clustered SEs for the total effect and P-values
	#Try and catch errors with clustered standard errors

	tryCatch(test_matrix <- coeftest(model1, vcov.=vcv_matrix),
		 error = function (e){
			 print(e)
			 skip_variant <<-TRUE}
		 )
	 if(skip_variant) { next } 
	
    if(  is.na(output$BETA_MODEL1_0[i]) | is.na(output$BETA_TOTAL[i])) {
        output$SE_BETA_MODEL1_0[i] <- NA
        output$SE_BETA_TOTAL[i] <- NA
        output$P_BETA_MODEL1_0[i] <- NA
        output$P_BETA_TOTAL[i] <- NA
    } else {
        output$SE_BETA_MODEL1_0[i] <- test_matrix[1,2] 
        output$SE_BETA_TOTAL[i] <- test_matrix[2,2]
        output$P_BETA_MODEL1_0[i] <- test_matrix[1,4] 
        output$P_BETA_TOTAL[i] <- test_matrix[2,4] 
 
    }
    

    # Run unified regression
    skip_variant <- FALSE
	tryCatch(model2 <- lm(formula = PHENOTYPE ~ FAM_MEAN + CENTREDGENOTYPE + AGE + SEX+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+PC11+PC12+PC13+PC14+PC15+PC16+PC17+PC18+PC19+PC20, data=ped3),
		 error = function(e){ 
			 print(e)
			 skip_variant <<- TRUE}
		)

	if(skip_variant) { next } 
	
    # Sample size in regression
    output$N_REG[i] <- length(resid(model2))
    
    # Save Beta information
    output$BETA_MODEL2_0[i] <- model2$coefficients[1]
    output$BETA_BF[i] <- model2$coefficients[2]
    output$BETA_WF[i] <- model2$coefficients[3]
    
    
    # save the variance covariance matrix
   tryCatch(vcv_matrix <- vcovCL(model2, cluster=ped3$FID),
	    error = function(e){
		    print(e)
		    skip_variant <<- TRUE}
	    )
		if(skip_variant) { next } 
	
    if(  is.na(output$BETA_MODEL2_0[i]) | is.na(output$BETA_BF[i]) | is.na(output$BETA_WF[i]) ) {
        output$VCV_MODEL2_0[i] <-NA
        output$VCV_MODEL2_0_BF[i] <-NA
        output$VCV_MODEL2_0_WF[i] <-NA
        output$VCV_MODEL2_BF[i] <-NA
        output$VCV_MODEL2_BF_WF[i] <-NA
        output$VCV_MODEL2_WF[i] <-NA
    } else {
        output$VCV_MODEL2_0[i] <- vcv_matrix[1,1]
        output$VCV_MODEL2_0_BF[i] <- vcv_matrix[1,2]
        output$VCV_MODEL2_0_WF[i] <- vcv_matrix[1,3]
        output$VCV_MODEL2_BF[i] <- vcv_matrix[2,2]
        output$VCV_MODEL2_BF_WF[i] <- vcv_matrix[2,3]
        output$VCV_MODEL2_WF[i] <- vcv_matrix[3,3]
    }

    # save the clustered SEs and corresponding P-values for WF/BF
    tryCatch(test_matrix <- coeftest(model2, vcov.=vcv_matrix),
	     error = function(e){
		     print(e)
		     skip_variant <<-TRUE}
	     )
	if(skip_variant) { next } 
		    
	
    if(  is.na(output$BETA_MODEL2_0[i]) | is.na(output$BETA_BF[i]) | is.na(output$BETA_WF[i]) ) {
        output$SE_BETA_MODEL2_0[i] <- NA
        output$SE_BETA_BF[i] <- NA
        output$SE_BETA_WF[i] <- NA
        output$P_BETA_MODEL2_0[i] <- NA
        output$P_BETA_BF[i] <- NA
        output$P_BETA_WF[i] <- NA
    } else {
        output$SE_BETA_MODEL2_0[i] <- test_matrix[1,2] 
        output$SE_BETA_BF[i] <- test_matrix[2,2] 
        output$SE_BETA_WF[i] <- test_matrix[3,2] 
        output$P_BETA_MODEL2_0[i] <- test_matrix[1,4] 
        output$P_BETA_BF[i] <- test_matrix[2,4] 
        output$P_BETA_WF[i] <- test_matrix[3,4] 
    }
   
  
    if(i %% 1000 == 0) {
        print(paste0("Finished SNP ", i, " out of ",ncol(raw)-6)) 
        print(Sys.time()) 
    }
}

# Runtime:
proc.time()-ptm

# Write output:
fwrite(output, file = paste0(outfile,"_results.txt"), sep="\t")

# Close out
cat("Finished at: ")
Sys.time() 
cat("Elapsed time: ")
Sys.time() - time_start

# Exits R without storing the working space image
q("no")
