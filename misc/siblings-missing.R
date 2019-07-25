require(data.table)

#Insert your phenotype file with columns: FID, IID, Phenotype1... PhenotypeN
ph <- fread(" ", h=T)

phenlist<-names(ph)[-2:-1]
famlist<-unique(ph$FID)
out<-NULL

#Identifies families with phenotype data only in one individual

for (i in 1:length(phenlist)) {
		temp<-paste(phenlist[i])
		ph2<-subset(ph, select=c("FID", "IID", temp))
	for (j in 1:length(famlist)) {
		temp2<-paste(famlist[j])
		ph3<-ph2[which(ph2$FID==temp2),]
		names(ph3)<-c("FID", "IID", "Phenotype")
		ph4<-ph3[which(!is.na(ph3$Phenotype)),]
		number<-nrow(ph4)
		if(number==1)
	{
	mphen<-temp
	mfamily<-temp2
	df<-data.frame(mphen,mfamily)
	
	out<-rbind(out, df)
	}
		}
	     }

#Sets phenotype to missing for these individuals
for (i in 1:length(phenlist)) {
		x<-i+2
		temp<-paste(phenlist[i])
		test<-out[which(out$mphen==temp),]
		ph[[x]][ph$FID%in%test$mfamily]<-NA
}

#Add path for updated file name
write.table(ph, " ", quote=F, row.names=F)
