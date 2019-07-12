errorlist <- list()
warninglist <- list()

require(data.table)

# import argument

arguments <- commandArgs(trailingOnly = T)
relfile <- arguments[1]

#Read in PLINK relatedness output
rel <- fread(relfile, sep=" ")


#Check for monozyotic twins
relMZ<-rel[which(rel$PI_HAT>0.98),]
MZ<-nrow(relMZ)
message("Number of monozygotic twin-pairs in sample: ", MZ)

for (i in 1:length(relMZ)) {
  data<-rel[which(rel$FID1==relMZ$FID1[i] | rel$FID2==relMZ$FID1[i]),]
if(nrow(data)<2)
	{
	msg <-paste0("Identified family with only Monozygotic twins: Please check or remove the following families: ID ", data[1,1])
	errorlist<-c(errorlist, msg)

	warning("ERROR: ", msg)
  write.table(
	}
}

#Check Parents

relPARENTS<-rel[which(rel$Z1>0.98),]

if(nrow(relPARENTS)>0)
	{
	msg <-paste0("Identified Parent-offspring pairs: Please check or remove the following families: IDs ", data[1])
	errorlist<-c(errorlist, msg)
	warning("ERROR: ", msg)
	}
    
message("\n\nCompleted checks\n")

if(length(errorlist) > 0)
{
	message("\n\nThe following errors were encountered, and must be addressed before continuing:")
	null <- sapply(errorlist, function(x)
	{
		message("- ", x)
	})
	q(status=1)
}
