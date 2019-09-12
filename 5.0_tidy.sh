#!/bin/bash

set -e
source ./config

gwasoutcome=${1}

mkdir -p ${section_05_dir}
mkdir -p ${section_05_dir}/logs

## Sibling unified regression
echo "Merging results across batches..."

# Extract header from first results file
head -n1 ${section_04_dir}/output.1.${gwasoutcome}_results.txt > ${section_04_dir}/header.${gwasoutcome}.txt

# Remove headers from all files
sed -i '1d' ${section_04_dir}/output.*.${gwasoutcome}_results.txt > temp.

# Merge all files using a temporary file in case there's an error
cat ${section_04_dir}/header.${gwasoutcome}.txt ${section_04_dir}/output.*.${gwasoutcome}_results.txt > ${section_05_dir}/temporary_file.txt

#Finalise file
mv ${section_05_dir}/temporary_file.txt ${section_05_dir}/${study_name}.sumstats.${gwasoutcome}.txt

echo "Combined summary statistics file created!, now gzipping..."
gzip ${section_05_dir}/${study_name}.sumstats.${gwasoutcome}.txt

echo "Removing batch results files in SiblingGWAS/results/04 ..."
rm ${section_04_dir}/output.*.${gwasoutcome}_results.txt

echo "All finished!"

