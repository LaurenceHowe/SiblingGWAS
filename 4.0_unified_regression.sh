echo "Partitioning genotype file"
#Partition genotype file into chunks of 10,000 SNPs
split -l5 -d /mnt/storage/home/lh14833/Test/input_data/example.bim extract

#Number of SNPs in .bim file
snpnumber=$(wc -l < /mnt/storage/home/lh14833/Test/input_data/example.bim)

#Rounding for truncation and count number of files
round=$(echo "$((snpnumber+4))")
partitions=$(echo "$((round/n))")

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
