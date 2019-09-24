#!/bin/bash
plink=plink1.9

# This script check that the .fam files have the same IIDs and that they are in the correct order before replacing the file with the one that included FID

#prefix=/home/ubuntu/genotypes
#prefix2=/home/ubuntu/SiblingGWAS

# CHR1-23
for i in {1..23}
 do
        DIFF=$(diff <(cut -f2 -d ' ' update.fam) <(cut -f2 -d ' ' data_chr${i}_filtered.fam))

        if [ "$DIFF" == "" ]
        then

        cp update.fam data_chr${i}_filtered.fam

        else

        echo "The data_chr${i}_filtered.fam does not match"

        fi

 done

# Merged into one dataset for the second time with updated IDs
for i in {2..23}
do 
    echo "data_chr${i}_filtered"
done > mergefile.txt

$plink --bfile data_chr1_filtered --merge-list mergefile.txt --make-bed --out data_filtered

# Combine info files into a single file

head -n1 chr1_filtered.info > data_filtered.info

for i in {1..23}
do
    awk ' NR>1 {print $0}' < chr${i}_filtered.info |cat >> data_filtered.info
done

