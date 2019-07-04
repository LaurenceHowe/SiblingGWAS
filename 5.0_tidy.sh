#!/bin/bash

set -e
source ./config

mkdir -p ${section_05_dir}
mkdir -p ${section_05_dir}/logs

## Sibling unified regression
echo "Merging results across batches..."

# Extract header from first results file
head -n1 ${section_04_dir}/output.1_results.txt > ${section_04_dir}/header.txt

# Remove headers from all files
sed -i '1d' output/split*_sibs_WFunified_results.txt

# Merge all files
cat ${section_04_dir}/header.txt ${section_04_dir}/output* > ${section_05_dir}/combined.sumstats.txt

echo "All finished!"
