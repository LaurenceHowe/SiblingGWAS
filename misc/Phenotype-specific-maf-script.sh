##1) R script to extract lists of individuals who have data for each phenotype

R
#TO DO:
#a) Change path for phenotype file
#b) Change folder path for outname (inside the loop)

require(data.table)

#Read in phenotype file
phen <- fread("/SiblingGWAS/results/01/updated_phenotypes.txt")

#Columns 1/2 are FID/IID
numcols <- ncol(phen)
phenlist <- names(phen)[3 : numcols]

#Loop to generate list of IDs with data for each phenotype

for (i in 1:length(phenlist)) {

j <- i + 2
data <- data.table(FID = phen$FID, IID = phen$IID, Phen = phen[,j, with = F])
print(nrow(data))

#Restrict to complete cases
out <- data[complete.cases(data), ]

#Extract only FID/IID
out2 <- out[, c(1, 2)]
print(nrow(out2))

name <- phenlist[i]
outname <- paste("/users/lh14833/private/", name,".txt", sep = "") 
write.table(out2, outname, quote = F, row.names = F)
}

#Tweak path
write.table(phenlist, "/users/lh14833/private/phenlist.txt", quote = F, row.names = F, col.names = F)

##2) Extract MAFs using PLINK

#path to PLINK genotype file
bfile="/users/lh14833/private/data_filtered"

#Name of study
studyname="UKBiobank"

#path to folder containing the IDs from part 1, make sure you have the / at the end or will need to tweak below.
folder="/users/lh14833/private/"

#filename of the list of phenotypes
phenlist="/users/lh14833/private/phenlist.txt"

wc -l $phenlist

#Change to number of rows from wc -l above.
for i in {1..35}
do

#Extracting the ith phenotype name
j=$(sed -n "${i}p" $phenlist)

plink \
--bfile $bfile \
--keep $folder$j.txt \
--mpheno 1 \
--freq \
--out $studyname.$j

#Gzip the files in the interest of space
gzip $studyname.$j.frq

done

##Please send over the .frq.gz files!
##Thanks, Laurence

