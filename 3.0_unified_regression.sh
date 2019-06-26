#!/bin/bash

echo "Partitioning genotype file"

#Partition size
size=5
#Partition genotype file into chunks of x SNPs
split -l$size -d /mnt/storage/home/lh14833/Test/input_data/example.bim extract

#Number of SNPs in .bim file
snpnumber=$(wc -l < /mnt/storage/home/lh14833/Test/input_data/example.bim)

#Rounding for truncation and count number of files

round=$(echo "$((snpnumber+$size-1))")
partitions=$(echo "$((round/$size))")

echo "Running analysis"
#Run analysis on partitioned files
for i in $(seq 1 $partitions); do
(
j=$(echo "$((i-1))")
k=`printf "%02d" $j`

#Convert to .raw
plink \
--bfile /mnt/storage/home/lh14833/Test/input_data/example \
--extract extract${k} \
--recodeA \
--out temp.${i}

#Run regression script in R
Rscript resources/regression/unified_regression.R \
temp.${i}.raw \
extract${k} \
output.${i}

#Remove .raw file
rm temp.${i}*
rm extract${k}
)
done

echo "Completed analysis"
