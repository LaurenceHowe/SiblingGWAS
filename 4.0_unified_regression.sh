echo "Processing data and running regressions..."

echo "Partitioning genotype file"
#Partition genotype file

declare -a arr=()

#Convert to .raw

for num in "${arr[@]}"; do 									
	(
  #Convert to .raw
	plink \
  --bfile ${a} \
  --extract partition.{a} \
  --recodeA \
  --out temp.{a}.raw
	

	
	Rscript resources/regression/unified_regression.R \
        ${arg1} \
        ${arg2} \
        ${arg3}
        
rm temp.{a}.raw
	) 
done

wait
