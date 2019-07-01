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
phen <- fread(phenfile)
cov <- fread(covfile)

phencov<-merge(phen,cov,by="IID")
ped<-merge(raw,phencov, by="IID")

# Create a new data.frame which will be filled with all necessary output information
output <- data.frame(CHR=bim$V1, SNP=bim$V2, BP=bim$V4, A1=bim$V5, A2=bim$V6, N_REG=NA, BETA_0=NA, BETA_BF=NA, BETA_WF=NA, SE_BETA_0=NA, SE_BETA_BF=NA, SE_BETA_WF=NA, P_BETA_0=NA, P_BETA_BF=NA, P_BETA_WF=NA, VCV_0=NA, VCV_0_BF=NA, VCV_0_WF=NA, VCV_BF=NA, VCV_BF_WF=NA, VCV_WF=NA, BETA_TOTAL=NA, SE_TOTAL=NA, P_TOTAL=NA)

#---------------------------------------------------------------------------------------------#
# loop over all SNPs in a chromosome (should take about 10 hrs)
#---------------------------------------------------------------------------------------------#
paste0("Looping...")
ptm <- proc.time()

# loop over all SNPs
snps <- grep("rs[0-9]", colnames(ped), value = T)

for (i in 1:length(snps)) {
    # Calculate the Callrate: for how many sibs the SNP is available
    snp_ind <- i+6 


    # Make a matrix with: [FID PHENOTYPE] [individ - family mean ] [family mean]
    ped2 <- data.table(FID=ped$FID, PHENOTYPE=ped$PHENOTYPE, GENOTYPE=as.numeric(unlist(ped[,snp_ind, with=F])), FAM_MEAN=ave(as.numeric(unlist(ped[,snp_ind, with=F])), ped$FID, FUN=mean))
    ped3 <- na.omit(ped2[,GENOTYPE:=GENOTYPE-FAM_MEAN])

    # Run unified regression
    fit <- lm(formula = PHENOTYPE ~ FAM_MEAN + GENOTYPE, data=ped3)
    
    # Extract total effect
    total <-lm(formula=PHENOTYPE + GENOTYPE, data=ped2)
    
    # Sample size in regression
    output$N_REG[i] <- length(resid(fit))
    
    # Save Beta information
    output$BETA_0[i] <- fit$coefficients[1]
    output$BETA_BF[i] <- fit$coefficients[2]
    output$BETA_WF[i] <- fit$coefficients[3]
    output$BETA_TOTAL[i]<-total$coefficients[2]
    output$SE_TOTAL[i]<-summary(total)$coefficients[2,2]
    output$P_TOTAL[i]<-summary(total)$coefficients[2,4]
    # save the variance covariance matrix
    vcv_matrix = vcovCL(fit, cluster=ped3$FID)
    if(  is.na(output$BETA_0[i]) | is.na(output$BETA_BF[i]) | is.na(output$BETA_WF[i]) ) {
        output$VCV_0[i] <-NA
        output$VCV_0_BF[i] <-NA
        output$VCV_0_WF[i] <-NA
        output$VCV_BF[i] <-NA
        output$VCV_BF_WF[i] <-NA
        output$VCV_WF[i] <-NA
    } else {
        output$VCV_0[i] <- vcv_matrix[1,1]
        output$VCV_0_BF[i] <- vcv_matrix[1,2]
        output$VCV_0_WF[i] <- vcv_matrix[1,3]
        output$VCV_BF[i] <- vcv_matrix[2,2]
        output$VCV_BF_WF[i] <- vcv_matrix[2,3]
        output$VCV_WF[i] <- vcv_matrix[3,3]
    }

    # save the clustered SE's and corresponding p-values
    test_matrix <- coeftest(fit, vcov.=vcv_matrix)
    if(  is.na(output$BETA_0[i]) | is.na(output$BETA_BF[i]) | is.na(output$BETA_WF[i]) ) {
        output$SE_BETA_0[i] <- NA
        output$SE_BETA_BF[i] <- NA
        output$SE_BETA_WF[i] <- NA
        output$P_BETA_0[i] <- NA
        output$P_BETA_BF[i] <- NA
        output$P_BETA_WF[i] <- NA
    } else {
        output$SE_BETA_0[i] <- test_matrix[1,2] 
        output$SE_BETA_BF[i] <- test_matrix[2,2] 
        output$SE_BETA_WF[i] <- test_matrix[3,2] 
        output$P_BETA_0[i] <- test_matrix[1,4] 
        output$P_BETA_BF[i] <- test_matrix[2,4] 
        output$P_BETA_WF[i] <- test_matrix[3,4] 
    }

    if(i %% 1000 == 0) {
        print(paste0("Finished SNP ", i, " out of ",ncol(ped)-6)) 
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
