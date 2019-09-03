# R script to update FID, keeping the order of individuals the same as the original PLINK file.

# Input
sibFID <- read.delim2("/home/ubuntu/genotypes/Siblings-FID.fam", header=F, sep=" ", as.is=T)
plinkFAM <- read.delim2("/home/ubuntu/genotypes/data_chr1_filtered.fam", header=F, sep=" ", as.is=T)

# There are some duplicate IID with different FIDS in "/mnt/ukb/siblingGWAS/data/Siblings-FID.fam"

# Delete the duplicate FIDs
sibFID2 <- sibFID[!duplicated(sibFID$V2),]

# Set order - must keep the same order as in the PLINK file
plinkFAM$id <- 1:nrow(plinkFAM)

# Merge
merged <- merge(x = sibFID2, y = plinkFAM, by = "V2", sort = FALSE, all=T)

# Order
ordered <- merged[order(merged$id), ]

# Check dim
dim(plinkFAM)
dim(ordered)

# Format the file
ordered$V2 <- NULL
ordered$id <- NULL

# Add IID as FID for missing
ordered$V1.x[is.na(ordered$V1.x)] <- ordered$V1.y[is.na(ordered$V1.x)]

# Output
write.table(ordered, "/home/ubuntu/genotypes/update.fam", quote=F, row.names=F, col.names=F, sep=" ")
