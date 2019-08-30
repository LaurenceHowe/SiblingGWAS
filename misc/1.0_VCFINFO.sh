#!/bin/bash

# Copy perl script to genotypes directory

cp /home/ubuntu/SiblingGWAS/misc/get_vcf_chr_pos_info.pl /home/ubuntu/genotypes/ 

#CHR1:22
parallel --link "perl get_vcf_chr_pos_info.pl CHR{1}.HRC_WGS.vcf.gz MAF,R2 > mafinfo.minimac3.chr{2}.txt" ::: {01..22} ::: {1..22}

#CHR_X

perl get_vcf_chr_pos_info.pl CHR_X.HRC.vcf.gz MAF,R2 > mafinfo.minimac3.chr23.txt

	# Assumes column 2 is the position
    	# Assumes columns 4 and 5 are the allele names
        # Assumes column 8 is the MAF
     	# Assumes columns 9 is the info score

wait

parallel "awk -v chr={1} '{
           if (($4 == "A" || $4 == "T" || $4 == "C" || $4=="G") &&  ($5 == "A" || $5 == "T" || $5 == "C" || $5 == "G"))
           print "chr"chr":"$2":SNP", $8, $9;
           else
	   print "chr"chr":"$2":INDEL", $8, $9;
	   }' mafinfo.minimac3.chr{1}.txt |perl -pe 's/R2/Info/g'|perl -pe 's/chr[0-9][0-9]\:POS\:INDEL/SNP/g'|perl -pe 's/chr[0-9]\:POS\:I	NDEL/SNP/g' |awk '$2>0.01 && $3>0.8 {print $0}' > data_chr{1}.info" ::: {1..23}

wait

parallel "awk 'NR>1 {print $1}' < data_chr{1}.info > data_chr{1}.keep" ::: {1..23}

