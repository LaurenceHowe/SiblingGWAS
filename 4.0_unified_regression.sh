#!/bin/bash

set -e
source ./config

mkdir -p ${section_04_dir}
mkdir -p ${section_04_dir}/logs

exec &> >(tee ${section_04_logfile})

batch_number=${1}
phenotype=${2}
re='^[0-9]+$'

if ! [[ $batch_number =~ $re ]] ; then
	echo "error: Batch variable is not a number"
	echo "Usage: ${0} [batch number]"
	exit 1
fi

if ! [ $phenotype ="Height"] |![ $phenotype="BMI"] ; then
	echo "error: Phenotype not recognised."
	exit 1
fi

j=$(echo "$((batch_number-1))")
k=`printf "%02d" $j`

echo "Running analysis"
#Run analysis on partitioned files

#Convert to .raw
plink \
--bfile ${bfile_raw} \
--allow-no-sex \
--extract ${section_03_dir}/extract${k} \
--recodeA \
--out ${section_04_dir}/temp.${batch_number}

#Run regression script in R
Rscript resources/regression/unified_regression.R \
${section_04_dir}/temp.${batch_number}.raw \
${section_03_dir}/extract${k} \
${phenotypes} \
${covariates} \
${section_04_dir}/output.${batch_number}

#Remove .raw file
rm ${section_04_dir}/temp.${i}*
rm ${section_03_dir}/extract${k}
)
done

echo "Completed analysis"
