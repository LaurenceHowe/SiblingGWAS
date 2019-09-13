#!/bin/bash

# Copy perl script to genotypes directory

#1/3cp /home/ubuntu/SiblingGWAS/misc/get_vcf_chr_pos_info.pl /home/ubuntu/genotypes/ 

#CHR1:22
#2/3parallel --link "perl get_vcf_chr_pos_info.pl CHR{1}.HRC_WGS.vcf.gz MAF,R2 > mafinfo.minimac3.chr{2}.txt" ::: {01..22} ::: {1..22}

#CHR_X

#3/3perl get_vcf_chr_pos_info.pl CHR_X.HRC.vcf.gz MAF,R2 > mafinfo.minimac3.chr23.txt

	# Assumes column 2 is the position
    	# Assumes columns 4 and 5 are the allele names
        # Assumes column 8 is the MAF
     	# Assumes columns 9 is the info score

wait

# Function to do awk

#doawk() {
#	chr=$1
#	awk -v chr=$1 '{
#	           if (($4 == "A" || $4 == "T" || $4 == "C" || $4=="G") &&  ($5 == "A" || $5 == "T" || $5 == "C" || $5 == "G"))
#                      print "chr"chr":"$2":SNP", $8, $9;
#	                 else
#	              print "chr"chr":"$2":INDEL", $8, $9;
#	                }' mafinfo.minimac3.chr$chr.txt | perl -pe 's/R2/Info/g'| perl -pe 's/chr[0-9][0-9]\:POS\:INDEL/SNP/g' | perl -pe 's/chr[0-9]\:POS\:INDEL/SNP/g' | awk '$2 > 0.01 && $3>0.8 {print $0}' > data_chr$chr.info
#	}

#export -f doawk

#parallel doawk ::: {1..23}

for i in {1..23}
do
awk -v chr=$i '{
           if (($4 == "A" || $4 == "T" || $4 == "C" || $4=="G") &&  ($5 == "A" || $5 == "T" || $5 == "C" || $5 == "G"))
		   print "chr"chr":"$2":SNP", $8, $9;
	   else
		   print "chr"chr":"$2":INDEL", $8, $9;
		   	}' mafinfo.minimac3.chr$i.txt | perl -pe 's/R2/Info/g'| perl -pe 's/chr[0-9][0-9]\:POS\:INDEL/SNP/g' | perl -pe 's/chr[0-9]\:POS\:INDEL/SNP/g' | awk '$2 > 0.01 && $3>0.8 {print $0}' > data_chr$i.info

awk 'NR >1 {print $1}' < data_chr$i.info > data_chr$i.keep

done

