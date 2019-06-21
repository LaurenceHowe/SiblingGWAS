echo "Partitioning genotype file"
#Partition genotype file into chunks of 10,000 SNPs
split -l10000 -d example.bim extract

#Number of SNPs in .bim file
snpnumber=$(wc -l < example.bim)

#Rounding for truncation and count number of files
round=$(echo "$((snpnumber+999))")
partitions=$(echo "$((round/n))")

echo "Running analysis"
#Run analysis on partitioned files
for i in $(seq 1 $partitions); 
do 
j=$(echo "$((i-1))")
k=`printf "%02d" $j`

#Convert to .raw
plink \
--bfile example \
--extract extract${k} \
--recodeA \
--out temp.${i}

#Run regression script in R
Rscript resources/regression/unified_regression.R \
temp.${i} \
output.${i}

#Remove .raw file
rm temp.${i}*;
done

echo "Completed analysis"
